# set output folder
out_folder <- "~/Dropbox (UW)/ris_test/test_output/"

# select an RIS file
in_file <- file.choose()

# open connection to file
con <- file(in_file, "r")

# function to strip line of data type info
strip_type <- function(line) {
  return(substr(line, 7, nchar(line)))
}

# function to reorder author name
fix_author <- function(line) {
  comma_char <- regexpr(",", line)[1]
  return(paste(substr(line, comma_char + 2, nchar(line)),
               substr(line, 1, comma_char - 1)))
}

# function to reorder date
fix_date <- function(line) {
  if(grepl("^JAN",line)) {
    return("01")
  } else if(grepl("^FEB",line)) {
    return("02")
  } else if(grepl("^MAR",line)) {
    return("03")
  } else if(grepl("^APR",line)) {
    return("04")
  } else if(grepl("^MAY",line)) {
    return("05")
  } else if(grepl("^JUN",line)) {
    return("06")
  } else if(grepl("^JUL",line)) {
    return("07")
  } else if(grepl("^AUG",line)) {
    return("08")
  } else if(grepl("^SEP",line)) {
    return("09")
  } else if(grepl("^OCT",line)) {
    return("10")
  } else if(grepl("^NOV",line)) {
    return("11")
  } else if(grepl("^DEC",line)) {
    return("12")
  } else {
    return("ERROR")
  }
}

# read file
while(TRUE) {
  # read next line
  line = readLines(con, n = 1)
  
  # exit at end of file
  if(length(line) == 0) {
    break
  } else if(grepl("^TY", line)) {
    
    # create blank output fields
    title = ""
    authors = character()
    publication = ""
    date = ""
    doi = ""
    volume = ""
    issue = ""
    
    while(!grepl("^ER", line)) {
      # read next line
      line = readLines(con, n = 1)
      
      # sort by data type in record
      if(grepl("^TI", line)) {
        title <- strip_type(line)
      } else if(grepl("^AU", line)) {
        authors <- append(authors,
                          fix_author(strip_type(line)))
      } else if(grepl("^T2", line)) {
        publication <- strip_type(line)
      } else if(grepl("^DA", line)) {
        month <- fix_date(strip_type(line))
        date <- ifelse(grepl("[[:digit:]]", line),
                       substr(line, 
                              gregexec("[[:digit:]]",line)[[1]][1,1], 
                              gregexec("[[:digit:]]",line)[[1]][1,2]),
                       "01")
      } else if(grepl("^PY", line)) {
        year <- strip_type(line)
      } else if(grepl("^DO", line)) {
        doi <- strip_type(line)
      } else if(grepl("^VL", line)) {
        volume <- strip_type(line)
      } else if(grepl("^IS", line)) {
        issue <- strip_type(line)
      }
    }
    
    # create new folder
    new_folder <- paste0(out_folder,
                         paste(tail(strsplit(authors[1],split=" ")[[1]],1),
                               head(strsplit(publication,split=" ")[[1]],1),
                               head(strsplit(title,split=" ")[[1]],1),
                               substr(date,1,4),
                               sep = "_"))
    dir.create(new_folder)
    
    # write to new file
    sink(file = paste0(new_folder, "/index.md"),
         type = "output")
    writeLines("---")
    # write authors
    writeLines("authors:")
    for(i in 1:length(authors)) {
      writeLines(paste0("- ", authors[i]))
    }
    # write date
    writeLines(paste0("date: '", ifelse(month == "", 
                                       paste0(Sys.Date() - 365, "T00:00:00Z"),
                                       paste0(year, "-",
                                              month, "-",
                                              date, "T00:00:00Z")), "'"))
    writeLines(paste0("publishDate: '", ifelse(month == "", 
                                              paste0(Sys.Date() - 365, "T00:00:00Z"),
                                              paste0(year, "-",
                                                     month, "-",
                                                     date, "T00:00:00Z")), "'"))
    # write doi & url
    writeLines(ifelse(doi == "", 
                      "",
                      paste0("doi: '", doi, "'")))
    writeLines(ifelse(doi == "", 
                      "",
                      paste0("url_pdf: 'https://doi.org/", doi, "'")))
    # write publication
    writeLines(paste0("publication: '*",
                      publication,
                      ifelse(volume == "",
                             "",
                             paste0(", ", volume)),
                      "*",
                      ifelse(issue == "",
                             "",
                             paste0("(", issue, ")")),
                      "'"))
    # write title
    writeLines(paste0("title: '", title, "'"))
    writeLines("---")
    sink()
  } 
}

close(con)
