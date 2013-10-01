#/*
 #* ----------------------------------------------------------------------------
 #* "THE BEER-WARE LICENSE" (Revision 42):
 #* <quelques.centimes@gmail.com> wrote this file. As long as you retain this notice you
 #* can do whatever you want with this stuff. If we meet some day, and you think
 #* this stuff is worth it, you can buy me a beer in return. Centime
 #* ----------------------------------------------------------------------------
 #*/

jQuery ->

	# Feed
	class Feed extends Backbone.Model
		defaults:
			name: "MyFeed",
			rss: "httlp://myfeed.com/rss",
			position: 0,
			display: true

	# FeedView
	class FeedView extends Backbone.View

		tagName: "div"
		className: "feed"

		initialize: ->
			_.bindAll @


		render: (feedSize) ->
			if typeof feedSize == 'string'
				@feedSize = feedSize
			$(@el).attr "class","span"+@feedSize

			@name = $("<h2>",{ class: 'feed_name', text: @model.get('name'), title: @model.get('name') })
			$(@el).append @name

			@newName = $("<div>",{ class: 'new_name' })
			@newName.append $("<input>",{ class: 'new_name', value: @model.get('name') })
			@newName.append $("<br>")
			$(@el).append @newName
			@newName.hide()

			@control = $("<div>")
			@control.append $("<div>",{ class: "move_left"})
			@control.append $("<div>",{ class: "move_right"})
			@control.append $("<div>",{ class: "hide"})
			@control.append $("<div>",{ class: "show"})
			@control.append $("<div>",{ text: "", class: "rename"})
			@control.append $("<img>",{ src: 'img/remove.png', class: "remove"})
			$(@el).append @control
			@control.hide()

			@links = $("<div>", { id: "links"})
			$(@el).append @links
			@getFeed( @model.get('rss'), @links )
			if not @model.get('display')
				@links.hide()

			@el

		getFeed : (url, el) ->
			appendLinks = (data, el) ->
				entries = data.responseData.feed.entries
				for entry in entries
					link=$('<div>', {class: "link", title:entry.title})
						.append $('<a>',{ text:entry.title, href:entry.link, target:entry.link })
						.append ('<br>')
					el.append(link)

			$.ajax
				url: 'http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&callback=?&q=' + encodeURIComponent(url),
				dataType: 'json'
				error: (jqXHR, textStatus, errorThrown) ->
					alert "AJAX Error: #{textStatus}"
				success: (data) ->
					appendLinks data, el


		control: ->
			if @control.is ":hidden"
				@control.show 'slow'
			else
				@control.hide 'slow'

		left: ->
			$(@el).prev().before $(@el)
			@model.collection.upFeed( @model )

		right: ->
			$(@el).next().after $(@el)
			@model.collection.downFeed( @model )

		hide: ->
			@links.hide 'slow'
			@control.hide 'slow'
			@model.set 'display': false
			@model.save()

		show: ->
			@links.show 'slow'
			@control.hide 'slow'
			@model.set 'display': true
			@model.save()

		rename: ->
			@name.hide()
			@newName.show()
			input = @newName.find("input")
			val = input.val()
			input.focus().val('').val( val )

		rename_kp: (e)->
			if e.which == 13
				@model.set 'name':@newName.find("input").val()
				@newName.hide()
				@name.show()
				@model.save()
				@name.text @newName.find("input").val()
				@control.hide 'slow'

		remove: ->
			$(@el).remove()
			@model.collection.removeFeed(@model)


		events:
			'click .feed_name': 'control',
			'click .move_left': 'left',
			'click .move_right': 'right',
			'click .show': 'show',
			'click .hide': 'hide',
			'click .rename': 'rename',
			'keypress .new_name': 'rename_kp',
			'click .remove': 'remove'


	# Feeds
	class Feeds extends Backbone.Collection
		model: Feed,
		localStorage: new Backbone.LocalStorage("SlakeRss")

		initialize: ->
			@fetch()
			@sort()
			@index()


		comparator: (a,b) ->
			a=a.get "position"
			b=b.get "position"
			a > b ? 1 : a < b ? -1 : 0

		removeFeed: (feed)->
			feed.destroy()
			@index()

		index: ->
			i=0
			for feed in @models
				feed.set "position", i
				feed.save()
				i++

		upFeed: (feed)->
			index = feed.get( "position" )
			if  index > 0
				@models[index].set "position", index-1
				@models[index-1].set "position", index
				@sort()
				@index()

		downFeed: (feed)->
			index = feed.get( "position" )
			if  index < @models.length
				@models[index].set "position", index+1
				@models[index+1].set "position", index
				@sort()
				@index()


	# FeedsView
	class FeedsView extends Backbone.View

		el: $("#feeds")

		initialize: ->
			_.bindAll @
			@feeds = new Feeds
			#@feeds.fetch()
			@feeds.bind "add", @render

		render: (feedSize)->
			if typeof feedSize == 'string'
				@feedSize = feedSize
			$(@el).empty()
			for feed in @feeds.models
				feedView = new FeedView model: feed
				$(@el).append feedView.render( @feedSize )

		addNewFeed: ( name, rss )->
			newFeed = new Feed()
			newFeed.set "name":name, "rss":rss, "position":@feeds.models.length
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
			@feeds.render $('#slidebar').val()
			feed = document.location.href.split("?new_feed=")[1]
			if feed?
				if not @slackinception(feed)
					@getNewFeed feed
					document.location.href = document.location.href.substring(0,document.location.href.indexOf('?')-1)
			else
				$("#bookmark").attr "href", "javascript:if(document.documentElement.id=='feedHandler'){rss=document.location;}else{var%20links=document.getElementsByTagName('link');for%20(var%20i=0;links[i];++i){if%20(links[i].getAttribute('type')=='application/rss+xml'%20&&%20links[i].hasAttribute('href')){var%20rss=(links[i].getAttribute('href'));break}}};document.location='"+document.location+"?new_feed='+document.location.href+'__SlackeRss__'+rss"


		getNewFeed: (feed)->
			precutSubstring = (str, sub)->
				if ~str.indexOf sub
					str = str.substring sub.length, str.length
				str
			cutLastChar = (str, chr)->
				if str[str.length-1]==chr
					str = str.substring(0, str.length-1)
				str

			url = feed.split("__SlackeRss__")[0]
			rss = feed.split("__SlackeRss__")[1]

			rss = cutLastChar rss, '/'

			if rss=="undefined"
				alert "No valid RSS link found for this feed. Please enter it manually"
				return

			domain = url.split("/")[2]

			domain = precutSubstring domain, 'http://'
			domain = precutSubstring domain, 'www.'

			if rss.indexOf(domain) == -1
				domain = cutLastChar domain, '/'
				if rss[0]=="/"
					rss = rss.substring(1, rss.length)
				rss = 'http://'+domain+'/'+rss

			url = cutLastChar url, '/'
			url = precutSubstring url, 'http://'
			url = precutSubstring url, 'https://'
			url = precutSubstring url, 'www.'
			#alert url+" "+rss
			@feeds.addNewFeed( url, rss )

		slackinception: (feed)->
			if feed.split("__SlackeRss__")[0]==document.location.href.split("?new_feed=")[0]
				$("#main").empty()
				$("#main").append $("<img>",{src: "img/nuclear_bomb.jpg"})
				return true
			false

		openNewFeed: ->
			c=$("#panel_new_feed")
			if c.is(':hidden')
				c.show 'slow'
			else
				c.hide 'slow'

		addNewFeed: (e)->
			if e.which == 13
				@feeds.addNewFeed $("#new_feed_name").val(), $("#new_feed_rss").val()
				$("#panel_new_feed").hide 'slow'

		resize: ->
			@feeds.render $('#slidebar').val()

		events:
			"click #open_new_feed": "openNewFeed",
			"change #slidebar": "resize"
			"keypress #new_feed": "addNewFeed",

	feedsView = new AppView
