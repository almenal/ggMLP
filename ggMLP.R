library(tidyverse)

ggMLP = function(nodes_list, linewd=.5, node_sep='compact'){
  # Given a vector of the number of nodes per layer, 
  # draw a fully connected neural network

  L = as.numeric(nodes_list)
  largest_layer = which.max(L)
  top_node = max(L)
  central_node = mean(1:L[[largest_layer]])
  intercepts = sapply(L, function(x) central_node - mean(1:x))
  
  # Nodes
  if (node_sep == 'compact'){
    
    nodes_df = lapply(seq_along(L),  function(i){
      
      pos = as.character(i)
      nodes = (intercepts[[i]] + 1:L[[i]])
      
      return(expand.grid('position'=pos, 'node'= nodes))
      }) %>% bind_rows()
    
  } else if (node_sep == 'even'){
    
    nodes_df = lapply(seq_along(nodes_list),  function(i){
      
      pos = as.character(i)
      bin_height = top_node / L[[i]]
      nodes = ((0:(L[[i]]-1))+0.5)*bin_height
      
      return(expand.grid('position'=pos, 'node'= nodes))
    }) %>% bind_rows()
    
  } else {
    stop('node_sep must be one of c("compact", "even")')
  }
  
  
  # Edges
  edges_df = lapply(1:(length(L)-1), function(i){
    
    from = nodes_df %>% filter(position == i)
    to = nodes_df %>% filter(position == i+1)
    combis = expand.grid('from_x'=from$position, 'from_y'=from$node, 
                         'to_x'=to$position, 'to_y'=to$node)
    return( combis )
  }) %>% bind_rows()
  
  
  # Plot
  ggplot() + 
    geom_segment(data = edges_df, size=linewd,
                 aes(x=from_x, xend =to_x, y=from_y, yend=to_y)) +
    geom_point(data = nodes_df,
               aes(position, node), shape=21, 
               size=8, stroke=2, fill='white') +
    theme_void()
}


## TEST ----
# mlp = c(2, 12, 7, 3)
# draw_MLP(mlp, .5, node_sep = 'compact')
# draw_MLP(mlp, .5, node_sep = 'even')
# draw_MLP(mlp, .5, node_sep = 'spam')

