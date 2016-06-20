#' @import httr
#' @import rjson
NULL

#' Query an InfluxDB database
#' 
#' @param host Character vector with IP address or hostname
#' @param port Port number
#' @param database The name of the database
#' @param query Character vector containing the InfluxDB query
#' @return A named list of data frames, where the names are the series names,
#'   and the data frames contain the points.
#'
#' @export
influxdb_query <- function (host, port = 8086, database, username = NULL, password = NULL, query) {
  
  PROTOCOL = "http"
  
  query = URLencode(gsub(pattern=" ", replacement="+", x=query))
  url = paste0(PROTOCOL, "://",host,":",port,"/query?db=",database,"&p=",password,"&q=",query,"&u=",username,"&time_precision=s")
  response = httr::GET(url)
  
  # Check for error. Not familiar enough with httr, there may be other ways it
  # communicates failure.
  if (response$status_code < 200 || response$status_code >= 300) {
    stop("Influx query failed with HTTP status code ", response$status_code)
  } else {
    # From json to a nested list.
    response_data <- rjson::fromJSON(rawToChar(response$content))
    if (length(response_data$results[[1]]) > 0) {
      # Get a list of dataframe (one for every table).
      dfLst <- lapply(response_data$results[[1]]$series, toDataFrame)
      # Fix the names.
      dfLst <- structure(dfLst, names = getNames(response_data$results[[1]]$series))
    }
    else {
      warning("Empty response from Influx")
      dfLst <- data.frame()
    }
  }
  return(dfLst)
  
}

# Need this function to transform every element in the list response_data$results[[1]]$series
# to a dataframe.
toDataFrame <- function(lst) {
  
  df <- as.data.frame(t(sapply(lst$values, rbind)), stringsAsFactors = FALSE)
  nullCol <- apply(df, 2, allNull)
  df <- df[,!nullCol]
  df <- as.data.frame(lapply(df, unlist), stringsAsFactors = FALSE)
  colnames(df) <- lst$columns[!nullCol]
  
  return(df)
}

# If we perform a query on multiple table (like "SELECT * FROM cpu,temperature") 
# the results will be mixed up. We need this function to check if a column is full of "NULL"
# values.
allNull <- function(lst) {
  
  t <- lst == "NULL"
  ifelse(sum(t) == length(lst), return(TRUE), return(FALSE))
  
}

# This function simply returns the names of the dataframes.
getNames <- function(lst) {
  
  return(sapply(lst, function(x){return(x$name)}))
  
}
