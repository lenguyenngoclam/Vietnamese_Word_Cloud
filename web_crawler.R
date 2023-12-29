## install packages
# install.packages("rvest")
# install.packages("readtext")
# install.packages("webdriver")
# install.packages("tidyverse")
# install.packages("readtext")
# install.packages("flextable")
# install.packages("webdriver")
# install.packages("arrow)
# install.packages("optparse")
# webdriver::install_phantomjs()
## install klippy for copy-to-clipboard button in code chunks
# install.packages("remotes")
# remotes::install_github("rlesur/klippy")

# load packages
library(optparse)
library(tidyverse)
library(arrow)
library(rvest)
library(readtext)
library(flextable)
library(webdriver)
# activate klippy for copy-to-clipboard button
klippy::klippy()

# Create new phantomjs session
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

get_article_link <- function(url){
  #' Get article link in current page given url
  #' 
  #' @param 
  #'  url : URL of main page
  #'
  #' @return 
  #'  article_links: Array of article links in URL
  #'  
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_content <- rvest::read_html(rendered_source) # parse html string to xml object
  
  article_links <- html_content |> 
                    rvest::html_elements(xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "item-news-common", " " ))]') |> 
                    rvest::html_elements("a") |> 
                    rvest::html_attr("href")
  final_article_links <- NULL
  
  for (link in article_links){
    if (str_detect(link, pattern = ".html$")){
      final_article_links <- c(final_article_links, link)
    }
  }
    
  final_article_links <- unique(final_article_links)
  
  return (final_article_links)
}

get_page_content <- function(url){
    #'Get page content in article
    #'
    #'@param 
    #'  url : Article's URL
    #'  
    #'@return
    #'  sentences: Array of sentence content in article
    #'  
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_content <- rvest::read_html(rendered_source) # parse html string to xml object
  
  # Get content
  sentences <- html_content |> 
              rvest::html_elements(xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "Normal", " " ))]') |> 
              rvest::html_text2()
  
  return (sentences)
}

scrape_vnexpress <- function(main_url, num_of_pages=10){
  print(str_glue("Processing url {main_url}", main_url = main_url))
  # Initialize empty articles tibble
  articles <- tibble(
    url = character(),
    sentence = character()
  )

  for (page_num in 1:num_of_pages){
    print(str_glue("Processing page num: {page_num}", page_num=page_num))
    if(page_num == 1){
      url <- main_url
    } else {
      url <- str_c(main_url, str_glue("-p{page_num}", page_num=page_num))
    }
    
    # Get article links
    article_links <- get_article_link(url)
    # Get content from each links
    for (link in article_links){
      sentences <- get_page_content(url = link)
      temp <- tibble(
        url = link,
        sentence = sentences
      )
      articles <- rbind(articles, temp)
    }
  }
  
  return (articles)
}

#article_links <- get_article_link(url = "https://vnexpress.net/khoa-hoc/phat-minh")
#print(article_links)
#sentences <- get_page_content(url = "https://vnexpress.net/nha-phat-minh-da-den-tung-canh-tranh-voi-thomas-edison-4684315.html")
#print(sentences)
option_list <- list(
  make_option(c("--page_url"),
              default="https://vnexpress.net/khoa-hoc/tin-tuc", 
              help="Page URL to crawl article from"),
  make_option(c("--num_of_pages"),
              default = 5,
              help = "Number of pages to crawl articles"),
  make_option(c("--store_path"), 
              default="article_contents",
              help = "Path to store article contents. 
                      The content will be stored in parquet format")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$page_url) | is.null(opt$num_of_pages) | is.null(opt$store_path)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

page_url <- opt$page_url
news_article_contents <-  scrape_vnexpress(
                        main_url = page_url, 
                        num_of_pages = opt$num_of_pages
                      )
news_article_contents |> write_dataset(
  path=opt$store_path, 
  format = "parquet"
) 
