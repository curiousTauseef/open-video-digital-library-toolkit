jQuery(document).ready(function() {
  jQuery('#login').click(function(){ jQuery('.popup').show();  });
  jQuery('#register').click(function(){ jQuery('.popup-reg').show();  });
  jQuery('.close img').click(function(){ jQuery('.popup').hide();  });
  jQuery('.close img').click(function(){ jQuery('.popup-reg').hide();  });
  /* SMP remove info'x' */
  jQuery('.categoryx, #details, .general-info').accordion({
    header: 'dt',
    event: 'click',
    autoheight: false
  });
  jQuery('ul.videos li.fifthx, .sm-thumbs .list li.fourth').after('<div class="clear"></div>');
  jQuery('.tabs ul, ul.navigators').tabs();
  
  jQuery('ul.videos li.fifth + li').css("clear", "left");
  
  function recent_carousel_initCallback( recent_carousel ) {

    jQuery(".panels #recent .jcarousel-clip > ul > li").each(function() {
      jQuery(this).attr('style', 'width:120px;');
    });

    var licount = jQuery(".panels #recent .jcarousel-clip > ul > li").length;
    var ulwidth = licount * 150;
    jQuery(".panels #recent .jcarousel-clip > ul").attr('style', 'width:' + ulwidth + 'px;');

    jQuery(".panels #recent .carousel_pager div").bind("click", function() {
      recent_carousel.scroll( jQuery.jcarousel.intval( jQuery(this).attr("page")*5+1 ) );
      return false;
    });

    jQuery(".panels .prev").bind("click", function() {
      if(jQuery('.panels #recent').is(':visible')){
        recent_carousel.prev();
      }
    });

    jQuery(".panels .next").bind("click", function() {
      if(jQuery('.panels #recent').is(':visible')){
        recent_carousel.next();
      }
    });
  }
  function recent_carousel_updatePagerCallback( recent_carousel, item, index, action ) {
    jQuery(".panels #recent .carousel_pager div").removeClass("active");
    page = jQuery.jcarousel.intval( (index - 1) / 5 );
    jQuery(".panels #recent .carousel_pager .carousel_page_" + page ).addClass("active");
  }
  jQuery(".panels #recent").jcarousel(
  {
    visible: 4,
    scroll: 5,
    wrap: "both",
    initCallback: recent_carousel_initCallback,
    itemFirstInCallback:  {
    onBeforeAnimation: null,
    onAfterAnimation: recent_carousel_updatePagerCallback
    }
  });

  function popular_carousel_initCallback( popular_carousel ) {
    jQuery(".panels #popular .jcarousel-clip > ul > li").each(function() {
      jQuery(this).attr('style', 'width:120px;');
    });

    var licount = jQuery(".panels #popular .jcarousel-clip > ul > li").length;
    var ulwidth = licount * 150;
    jQuery(".panels #popular .jcarousel-clip > ul").attr('style', 'width:' + ulwidth + 'px;');

    jQuery("#popular .carousel_pager div").bind("click", function() {
      popular_carousel.scroll( jQuery.jcarousel.intval( jQuery(this).attr("page")*5+1 ) );
      return false;
    });

    jQuery(".panels .prev").bind("click", function() {
      if(jQuery('.panels #popular').is(':visible')){
        popular_carousel.prev();
      }
    });

    jQuery(".panels .next").bind("click", function() {
      if(jQuery('.panels #popular').is(':visible')){
        popular_carousel.next();
      }
    });

  }
  function popular_carousel_updatePagerCallback( popular_carousel, item, index, action ) {
    jQuery("#popular .carousel_pager div").removeClass("active");
    page = jQuery.jcarousel.intval( (index - 1) / 5 );
    jQuery("#popular .carousel_pager .carousel_page_" + page ).addClass("active");
  }
  jQuery(".panels #popular").jcarousel(
  {
    visible: 4,
    scroll: 5,
    wrap: "both",
    initCallback: popular_carousel_initCallback,
    itemFirstInCallback:  {
    onBeforeAnimation: null,
    onAfterAnimation: popular_carousel_updatePagerCallback
    }
  });


  function random_carousel_initCallback( random_carousel ) {
    jQuery(".panels #random .jcarousel-clip > ul > li").each(function() {
      jQuery(this).attr('style', 'width:120px;');
    });

    var licount = jQuery(".panels #random .jcarousel-clip > ul > li").length;
    var ulwidth = licount * 150;
    jQuery(".panels #random .jcarousel-clip > ul").attr('style', 'width:' + ulwidth + 'px;');

    jQuery("#random .carousel_pager div").bind("click", function() {
      random_carousel.scroll( jQuery.jcarousel.intval( jQuery(this).attr("page")*5+1 ) );
      return false;
    });

    jQuery(".panels .prev").bind("click", function() {
      if(jQuery('.panels #random').is(':visible')){
        random_carousel.prev();
      }
    });

    jQuery(".panels .next").bind("click", function() {
      if(jQuery('.panels #random').is(':visible')){
        random_carousel.next();
      }
    });

  }
  function random_carousel_updatePagerCallback( random_carousel, item, index, action ) {
    jQuery("#random .carousel_pager div").removeClass("active");
    page = jQuery.jcarousel.intval( (index - 1) / 5 );
    jQuery("#random .carousel_pager .carousel_page_" + page ).addClass("active");
  }
  jQuery(".panels #random").jcarousel(
  {
    visible: 4,
    scroll: 5,
    wrap: "both",
    initCallback: random_carousel_initCallback,
    itemFirstInCallback:  {
    onBeforeAnimation: null,
    onAfterAnimation: random_carousel_updatePagerCallback
    }
  });



});

jQuery(document).ready( function() {
    setTimeout( 'jQuery(".flash").effect("highlight", {}, 1000 );', 500 );
    setTimeout( 'jQuery(".flash.notice").fadeOut( 2000 );' , 2000 );
    //jQuery('a[rel*=facebox]').facebox({opacity:0.5})
} );
