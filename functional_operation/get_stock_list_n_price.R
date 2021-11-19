get_stock_list <-
function(stock_index = "SP500") {
        tq_index(stock_index) %>%
        select(symbol, company, sector) %>%
        arrange(symbol)
}
get_stock <-
function(stock_symbol,
                      from = today() - lubridate::days(730),
                      to = today()){
  stock_symbol %>%
    tq_get(get = "stock.prices", from = from, to = to) 
}
