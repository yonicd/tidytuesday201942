context("reactivity")

testthat::describe('reactive',{

  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  
  plot_counter <- reactor::test_whereami(expr = {
    
    #find geom point option
    
    elem1 <- reactor::asyncr(
      remDr,
      using = "css selector",
      value = '#raw_data > div > ul > li:nth-child(1) > a'
    )
    
    #click geom point option
    elem1$clickElement()
    
    #what is the current plot img src?
    plot_src <- reactor::asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src'
    )
    
    #find go button
    go_btn <- reactor::asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-go'
    )
    
    #click go button
    go_btn$clickElement()
    
    #wait for the plot to render and update the img src
    reactor::asyncr_update(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src',
      old_value = plot_src
    )
    
    
  })
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_count(plot_counter,'plot',2)
  })
  
  it('reactive hits of go tbn',{
    reactor::expect_count(plot_counter,'go',1)
  })
    
})

