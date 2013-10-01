jQuery ->

	# Feed
	class Feed extends Backbone.Model
		defaults: 
			name: "MyFeed",
			rss: "httlp://myfeed.com/rss",
		
		
	# FeedView
	class FeedView extends Backbone.View
		
		tagName: "div"
		className: "span4 feed"
		
		initialize: ->
			_.bindAll @
			@model.bind 'remove', @unrender
			
		
		render: ->
			$(@el).attr "id","feed"
			$(@el).append $("<h2>",{ class: 'feedName', text: @model.get('name'), title: @model.get('name') })
			@control = $("<div>")
			@control.append $("<input>",{ class: 'feed_name_input', value: @model.get('name') })
				.append $("<br>")
			@control.append $("<div>",{ class: "move_left"})
			@control.append $("<div>",{ class: "move_right"})
			@control.append $("<div>",{ text: "rename", class: "rename"})
			@control.append $("<img>",{ src: 'img/remove.png', class: "remove"})
			$(@el).append @control
			@control.hide()
			@links = $("<div>", { id: "links"})
			$(@el).append @links
			@getFeed( @model.get('rss'), @links )

			@
		
		getFeed : (url, el) ->
			appendLinks = (data, el) ->
				entries = data.responseData.feed.entries
				for entry in entries
					link=$('<div>', {class: "link", title:entry.title})
						.append $('<a>',{ text:entry.title, href:entry.link, target: "newtab"})
						.append ('<br>')			
					el.append(link)
					
			$.ajax 
				url: 'http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&callback=?&q=' + encodeURIComponent(url),
				dataType: 'json'
				error: (jqXHR, textStatus, errorThrown) ->
					alert "AJAX Error: #{textStatus}"
				success: (data) ->
					appendLinks data, el
		
		unrender: =>
			$(@el).remove()
		remove: -> 
			@model.destroy()
		control: ->
			if @control.is ":hidden"
				@control.show 'slow'
			else
				@control.hide 'slow'
				
		moveUp: ->
			@model.collection.moveUp(@model)
		moveDown: ->
			@model.collection.moveDown(@model)
			
		events: 
			'click .feedName': 'control',
			'click .remove': 'remove',
			'click .move_left': 'moveUp',
			'click .move_right': 'moveDown'
		

	# Feeds
	class Feeds extends Backbone.Collection
		model: Feed,
		localStorage: new Backbone.LocalStorage("test3"),
		
		moveUp: (model) ->
			index = this.indexOf(model)
			if (index > 0)
				this.remove(model, {silent: true}) 
				this.add(model, {at: index-1})
		  

		moveDown: (model) ->
			index = this.indexOf(model)
			if (index < this.models.length)
				this.remove(model, {silent: true}) 
				this.add(model, {at: index+1})
		  
		
	# FeedsView
	class FeedsView extends Backbone.View
		
		el: $("#feeds")
		
		initialize: ->
			_.bindAll @
			@feeds = new Feeds
			@feeds.fetch()
			@feeds.bind "add", @render		
			@render()
			
		render: ->
			$(@el).empty()
			for feed in @feeds.models
				feed.collection = @feeds
				feedView = new FeedView model: feed
				$(@el).append feedView.render().el
		
		addNewFeed: ( name, rss )->
			newFeed = new Feed()
			newFeed.set "name":name, "rss":rss
			for feed in @feeds.models
				if name == feed.get 'name'
					return
			@feeds.add(newFeed)
			newFeed.save()
	
	# AppView		
	class AppView extends Backbone.View
		
		el: $("body")
		
		initialize: ->
			_.bindAll @
			@feeds = new FeedsView
			feed = document.location.href.split("?new_feed=")[1]
			if feed?
				@getNewFeed feed 
		#		document.location.href = document.location.href.substring(0,document.location.href.indexOf('?')-1)
			else
				$("#bookmark").attr "href", "javascript:var%20links=document.getElementsByTagName('link');for%20(var%20i=0;links[i];++i){if%20(links[i].getAttribute('type')=='application/rss+xml'%20&&%20links[i].hasAttribute('href')){var%20rss=(links[i].getAttribute('href'));break}};document.location='"+document.location+"?new_feed='+document.location.href+'__SlackeRss__'+rss"
			
		
		getNewFeed: (feed)->
			url = feed.split("__SlackeRss__")[0]
			if url==document.location.href.split("?new_feed=")[0]
				$("#main").empty()
				$("#main").append $("<img>",{src: "img/nuclear_bomb.jpg"})
				return
			rss = feed.split("__SlackeRss__")[1]
			if rss=="undefined/"
				alert "No valid RSS link found for this feed. Please enter it manually"
				return
			domain = url.split("/")[2]
			if ~domain.indexOf("www.")
				domain = domain.substring "www.".length, domain.length
			if rss.indexOf(domain) == -1
				if domain[domain.length-1]=="/"
					domain = domain.substring(0, domain.length-1)
				if rss[0]=="/"
					rss = rss.substring(1, rss.length)
				rss = 'http://'+domain+'/'+rss
			if rss[rss.length-1]=="/"
				rss = rss.substring(0, rss.length-1)
			if url[url.length-1]=="/"
				url = url.substring(0, url.length-1)
			if ~url.indexOf("http://")
				url = url.substring "http://".length, url.length
			if ~url.indexOf("https://")
				url = url.substring "https://".length, url.length
			if ~url.indexOf("www.")
				url = url.substring "www.".length, url.length
		#alert url+" "+rss
			@feeds.addNewFeed( url, rss )
			
		
		openNewFeed: ->
			$("#panel_new_feed").show 'slow'
		closeNewFeed: ->
			$("#panel_new_feed").hide 'slow'
		addNewFeed: ->
			@feeds.addNewFeed $("#new_feed_name").val(), $("#new_feed_rss").val()
			$("#panel_new_feed").hide 'slow'
			
		events: 
			"click #open_new_feed": "openNewFeed",
			"click #close_new_feed": "closeNewFeed",
			"click #add_new_feed": "addNewFeed",
		
				
	feedsView = new AppView
