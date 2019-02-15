$(document).on('turbolinks:load', function() {
  var app_id = "TOQ4XQOWDP";
  var search_key = "90f548a9f6bb9108464d081db4c6a29a";
  $('#searchModal').on('shown.bs.modal', function () {
    var client = algoliasearch(app_id, search_key);
    var tracks = client.initIndex('Track');
    var releases = client.initIndex('Release');//.setSettings({attributesToSnippet: ['text:3','title']});
    var users = client.initIndex('User');
    var topics = client.initIndex('Topic');
    var posts = client.initIndex('Post');

    autocomplete('#aa-search-input', {}, [
        {
          source: autocomplete.sources.hits(tracks, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Tracks</div>',
            suggestion: function(suggestion) {
              return '<a href="/tracks/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.title.value + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(releases, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Releases</div>',
            suggestion: function(suggestion) {
              return '<a href="/releases/'+suggestion.objectID+'"><span><i>' +
                suggestion._highlightResult.title.value + '</i> '
                  + suggestion._highlightResult.text.value.slice(0, 140) + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(users, { hitsPerPage: 3 }),
          displayKey: 'first_name',
          templates: {
            header: '<div class="aa-suggestions-category">Users</div>',
            suggestion: function(suggestion) {
              return '<a href="/users/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.first_name.value + ' ' +
                suggestion._highlightResult.last_name.value +'</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(topics, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Topics</div>',
            suggestion: function(suggestion) {
              return '<a href="/topics/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.title.value 
                  + suggestion._highlightResult.text.value + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(posts, { hitsPerPage: 3 }),
          displayKey: 'text',
          templates: {
            header: '<div class="aa-suggestions-category">Posts</div>',
            suggestion: function(suggestion) {
              return '<a href="/chirp/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.text.value + '</span>';
            }
          }
        }
    ]);
    
    $('#aa-search-input').focus();
  });

  var search_input = $('.releases-search-input');

  if (search_input.length > 0) {
    var client = algoliasearch(app_id, search_key);
    var releases = client.initIndex('Release');

    search_input.bind('input',function(){
      if (this.value.length > 1) {
        releases.search(this.value, function(err, content) {
          var matched_ids = content.hits.map(a => a.objectID);
          if (matched_ids.length > 0) {
            $.ajax({
              url: '/search_releases',
              dataType: 'script',
              data: { ids: matched_ids }
              });
          }
        });
      } else if (this.value.length == 0) {
        Turbolinks.visit(location.toString());
      }
    });
  }
  
});
