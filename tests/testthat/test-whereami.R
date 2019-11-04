context("reactivity")

testthat::describe('reactive',{

  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  
  plot_counter <- testwhereami(expr = {
    
    elem1 <- asyncr(
      remDr,
      using = "css selector",
      value = '#raw_data > div > ul > li:nth-child(1) > a'
    )
    
    elem1$clickElement()
    
    plot_src <- asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src'
    )
    
    go_btn <- asyncr(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-go'
    )
    
    go_btn$clickElement()
    
    asyncr_update(
      remDr,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src',
      old_value = plot_src
    )
    
    
  })
  
  it('plot',{
    expect_count(plot_counter,'plot',2)
  })
  
  it('go',{
    expect_count(plot_counter,'go',1)
  })
    
})

