import torch

from itertools import count
from queue import PriorityQueue


class BeamSearch(object):
    """ Defines a beam search object for a single input sentence. """
    def __init__(self, beam_size, max_len, pad, stop: str = "default"):

        self.beam_size = beam_size
        self.max_len = max_len
        self.pad = pad
        self.stop = stop

        self.nodes = PriorityQueue() # beams to be expanded
        self.final = PriorityQueue() # beams that ended in EOS

        self._counter = count() # for correct ordering of nodes with same score

    def add(self, score, node):
        """ Adds a new beam search node to the queue of current nodes """
        self.nodes.put((score, next(self._counter), node))

    def add_final(self, score, node):
        """ Adds a beam search path that ended in EOS (= finished sentence) """
        # ensure all node paths have the same length for batch ops
        missing = self.max_len - node.length
        node.sequence = torch.cat((node.sequence.cpu(), torch.tensor([self.pad]*missing).long()))
        self.final.put((score, next(self._counter), node))

    def get_current_beams(self):
        """ Returns beam_size current nodes with the lowest negative log probability """
        nodes = []
        while not self.nodes.empty() and len(nodes) < self.beam_size:
            node = self.nodes.get()
            nodes.append((node[0], node[2]))
        return nodes

    def get_best(self):
        """ Returns final node with the lowest negative log probability """
        # Merge EOS paths and those that were stopped by
        # max sequence length (still in nodes)
        merged = PriorityQueue()
        for _ in range(self.final.qsize()):
            node = self.final.get()
            merged.put(node)

        for _ in range(self.nodes.qsize()):
            node = self.nodes.get()
            merged.put(node)

        node = merged.get()
        node = (node[0], node[2])

        return node
    
    def _default_prune(self):
        """ Removes all nodes but the beam_size-finished best ones (lowest neg log prob) """
        nodes = PriorityQueue() 
        # Keep track of how many search paths are already finished (EOS)
        finished = self.final.qsize()
        for _ in range(self.beam_size-finished):
            node = self.nodes.get()
            nodes.put(node)
        return nodes  

    def _constant_prune(self):
        """ Removes all nodes but the beam_size best ones (lowest neg log prob) """
        nodes = PriorityQueue()

        for _ in range(self.beam_size):
            node = self.nodes.get()
            nodes.put(node)            
        return nodes
    
    def _prune_stop_prune(self):
        nodes = PriorityQueue()
        #There must be at least one finished hyp to start pruning incomplete hyp
        if self.final.qsize()>0:
            while not self.nodes.empty() and nodes.qsize()<self.beam_size:
                node = self.nodes.get(timeout=1)
                #check if this incomplete hypothesis has lower log prob than the best finished
                if node[0] <= self.final.queue[0][0]:
                    #if it is lower, continue expanding this hyp at next time step
                    nodes.put(node)

        else:
            #If there are no finished beam's just keep the beam size constant
            for _ in range(self.beam_size):
                node = self.nodes.get()
                nodes.put(node)

        return nodes

    def prune(self):
        """ Prunes the search space at each decoding time step according to stop criterion"""

        if self.stop == "default":
            nodes = self._default_prune()
        elif self.stop == "constant":
            nodes = self._constant_prune()
        else:
            #pruning stop criterion
            nodes = self._prune_stop_prune()

        self.nodes = nodes


class BeamSearchNode(object):
    """ Defines a search node and stores values important for computation of beam search path"""
    def __init__(self, search, emb, lstm_out, final_hidden, final_cell, mask, sequence, logProb, length, completed: bool = False):

        # Attributes needed for computation of decoder states
        self.sequence = sequence
        self.emb = emb
        self.lstm_out = lstm_out
        self.final_hidden = final_hidden
        self.final_cell = final_cell
        self.mask = mask

        # Attributes needed for computation of sequence score
        self.logp = logProb
        self.length = length

        self.search = search

        if self.search.stop == "constant":
            #by default will be False
            self.completed = completed

    def eval(self, alpha=0.0):
        """ Returns score of sequence up to this node 

        params: 
            :alpha float (default=0.0): hyperparameter for
            length normalization described in in
            https://arxiv.org/pdf/1609.08144.pdf (equation
            14 as lp), default setting of 0.0 has no effect
        
        """
        normalizer = (5 + self.length)**alpha / (5 + 1)**alpha
        return self.logp / normalizer
        