#'Module Discoverer
#' 
#' A clique based Algorithm by Sebastian Vlaic to produce disease module from Differentially Expressed Genes 
#' 
#' 
#' @param diffgen A nx2 dataframe consisting of differentially expressed genes and their respective -log10 p values  
#' @param ppi_network A dataframe  PPi network of your choice 
#' @param pval_cutoff Numeric pvalue cutoff for choosing number of differentially expressed genes 
#' @param repeats Number of repeats to be performed for single seed run
#' @param times  Number of iterations to be performed 
#' @param p_val cutoff pvalue for significant cliques 
#' @return A MODifieR class object with disease module and settings 
#' @export
modulediscoverer <- function(diffgen, ppi_network, permutations = 10000, pval_cutoff = 1.3, repeats = 15,
                             times = 1000, p_val =0.01){
  source(system.file(package="MODifieR", "ModuleDiscovererDB.R"))

  # Retrieve settings
  default_args <- formals()
  user_args <- as.list(match.call(expand.dots = T)[-1])
  settings <- c(user_args, default_args[!names(default_args) %in% names(user_args)])

  colnames(diffgen) <- c("hgnc_symbol" , "p_val")
  ppi_network <- graph.data.frame(ppi_network , directed = FALSE)
  ppi_network <- simplify(ppi_network, remove.multiple = TRUE, remove.loops = TRUE)

  A <- get.adjacency(ppi_network)

  proteins <- rownames(A)
  colnames(A) <- NULL
  rownames(A) <- NULL

  degrees <- degree(ppi_network)

  vlist <- cbind("content" = 1:nrow(A), "weight" = rep(1, nrow(A)), "degree" = degrees)

  ensp <- symbol_to_prot(diffgen)

  background <-unique(ensp[,2])

  for_degs <- diffgen[diffgen[, 2] > pval_cutoff,]
  for_degs <- merge(for_degs , ensp )

  degs <- unique(for_degs[, 3])

  degs_random_datasets <- replicate(n = permutations, expr = sample(background,
                                                                    size = length(degs),
                                                                    replace = FALSE), simplify = F)

  cl = makeCluster(3) # initialize the cluster with 3 cores.
  doParallel::registerDoParallel(cl)

  db_results_singleSeed <<- foreach(j = 1:repeats, .combine = 'append') %dopar% {
    cat(paste("processing run:",j,'\n'))
    set.seed(j) # if we don't set a seed, each repeat will return identical results.
    db_results <- lapply(1:times, function(i){return(moduleDiscoverer.fragmentGraph(A=A, vlist=vlist, nbrOfSeeds=1, verbose=F))})
    return(db_results)
  }

  stopCluster(cl) # stop the cluster

  database_singleSeed = moduleDiscoverer.createDatabase(results=db_results_singleSeed,
                                                        proteins=proteins)

  input_singleSeed = moduleDiscoverer.db.create_MD_object(database=database_singleSeed,
                                                          foregrounds=list("NASH"=degs),
                                                          cores=5, background=background,
                                                          chunks=100,
                                                          randomDataSets=list(degs_random_datasets))

  result_singleSeed = moduleDiscoverer.db.testForCliqueEnrichment(database=database_singleSeed,
                                                                  input=input_singleSeed)

  result_singleSeed.ec = moduleDiscoverer.db.extractEnrichedCliques(database=database_singleSeed,
                                                                    result=result_singleSeed,
                                                                    p.value=p_val)

  module_singleSeed = moduleDiscoverer.module.createModule(result=result_singleSeed.ec)


  vertices <- data.frame(names(V(module_singleSeed)) , stringsAsFactors = FALSE)

  vertices <- prot_to_entrez(vertices)

  new_modulediscoverer_module <- list("module_genes" =  vertices,
                                      "graph" = module_singleSeed,
                                      "settings" = settings)

  return(new_modulediscoverer_module)

}
