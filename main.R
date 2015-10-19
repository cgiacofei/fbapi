library('googlesheets')
suppressPackageStartupMessages(library('dplyr'))

gs_copy(gs_gap(), to = "Gapminder")

gs_ls()

