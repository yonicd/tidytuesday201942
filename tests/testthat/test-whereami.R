context("reactivity")

testthat::describe('reactive',{

  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  
  plot_counter <- testwhereami(expr = {
    
    #find geom point option
    
    elem1 <- asyncr(
      remDr,
      using = "css selector",
      value = '#raw_data > div > ul > li:nth-child(1) > a'
    )
    
    #click geom point option
    elem1$clickElement()
    
    #what is the current plot img src?
    plot_src <- asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src'
    )
    
    #find go button
    go_btn <- asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-go'
    )
    
    #click go button
    go_btn$clickElement()
    
    #wait for the plot to render and update the img src
    asyncr_update(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src',
      old_value = plot_src
    )
    
    
  })
  
  it('reactive hits in plot reactive chunk',{
    expect_count(plot_counter,'plot',2)
  })
  
  it('reactive hits of go tbn',{
    expect_count(plot_counter,'go',1)
  })
    
})

