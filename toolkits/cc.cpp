/*
Copyright (c) 2014-2015 Xiaowei Zhu, Tsinghua University

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include <stdio.h>
#include <stdlib.h>

#include "core/graph.hpp"

double compute(Graph<Empty> * graph) {
  double exec_time = 0;
  exec_time -= get_time();

  VertexId * label = graph->alloc_vertex_array<VertexId>();
  VertexSubset * active_in = graph->alloc_vertex_subset();
  active_in->fill();
  VertexSubset * active_out = graph->alloc_vertex_subset();

  VertexId active_vertices = graph->process_vertices<VertexId>(
    [&](VertexId vtx){
      label[vtx] = vtx;
      return 1;
    },
    active_in
  );

  for (int i_i=0;active_vertices>0;i_i++) {
    #ifdef SHOW
    if (graph->partition_id==0) {
      printf("active(%d)>=%u\n", i_i, active_vertices);
    }
    #endif
    active_out->clear();
    active_vertices = graph->process_edges<VertexId,VertexId>(
      [&](VertexId src){
        graph->emit(src, label[src]);
      },
      [&](VertexId src, VertexId msg, VertexAdjList<Empty> outgoing_adj){
        VertexId activated = 0;
        for (AdjUnit<Empty> * ptr=outgoing_adj.begin;ptr!=outgoing_adj.end;ptr++) {
          VertexId dst = ptr->neighbour;
          if (msg < label[dst]) {
            write_min(&label[dst], msg);
            active_out->set_bit(dst);
            activated += 1;
          }
        }
        return activated;
      },
      [&](VertexId dst, VertexAdjList<Empty> incoming_adj) {
        VertexId msg = dst;
        for (AdjUnit<Empty> * ptr=incoming_adj.begin;ptr!=incoming_adj.end;ptr++) {
          VertexId src = ptr->neighbour;
          if (label[src] < msg) {
            msg = label[src];
          }
        }
        if (msg < dst) {
          graph->emit(dst, msg);
        }
      },
      [&](VertexId dst, VertexId msg) {
        if (msg < label[dst]) {
          write_min(&label[dst], msg);
          active_out->set_bit(dst);
          return 1u;
        }
        return 0u;
      },
      active_in
    );
    std::swap(active_in, active_out);
  }

  exec_time += get_time();
  if (graph->partition_id==0) {
    printf("exec_time=%lf(s)\n", exec_time);
  }

  graph->gather_vertex_array(label, 0);
  if (graph->partition_id==0) {
    VertexId * count = graph->alloc_vertex_array<VertexId>();
    graph->fill_vertex_array(count, 0u);
    for (VertexId v_i=0;v_i<graph->vertices;v_i++) {
      count[label[v_i]] += 1;
    }
    VertexId components = 0;
    for (VertexId v_i=0;v_i<graph->vertices;v_i++) {
      if (count[v_i] > 0) {
        components += 1;
      }
    }
    printf("components = %u\n", components);
  }
  
  graph->dealloc_vertex_array(label);
  delete active_in;
  delete active_out;

  return exec_time;
}

int main(int argc, char ** argv) {
  MPI_Instance mpi(&argc, &argv);

  if (argc<4) {
    printf("cc [file] [vertices] [rounds]\n");
    exit(-1);
  }
  int rounds = std::atoi(argv[3]);

  Graph<Empty> * graph;
  graph = new Graph<Empty>();
  graph->load_undirected_from_directed(argv[1], std::atoi(argv[2]));

  double aver_time=0;
  for (int run=0;run<rounds;run++) {
    aver_time+=compute(graph);
  }

  // int world_rank;
  // MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  // if(world_rank==0)
  //     printf("aver_time = %lf\n", aver_time/rounds);

  delete graph;
  return 0;
}