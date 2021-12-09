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
  year <- substr(line, 1, 4)
  month <- substr(line, 6, 7)
  day <- substr(line, 9, nchar(line)-1)
  if(is.na(as.numeric(day))) {
    day <- "01"
  }
  return(paste0(year, "-",
                month, "-",
                day, "T00:00:00Z"))
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
        date <- fix_date(strip_type(line))
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
    writeLines(paste0("date: '", ifelse(date == "", 
                                       paste0(Sys.Date(), "T00:00:00Z"),
                                       date), "'"))
    writeLines(paste0("publishDate: '", ifelse(date == "", 
                                              paste0(Sys.Date(), "T00:00:00Z"),
                                              date), "'"))
    # write doi & url
    writeLines(paste0("doi: '", ifelse(doi == "", 
                                      "",
                                      doi), "'"))
    writeLines(paste0("url_pdf: '", ifelse(doi == "", 
                                         "",
                                         paste0("https://doi.org/", doi, "'"))))
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
