$ ->
  unless $.support.cors = true
    msg = "Your browser doesn't appear to support all required features.
      Selecting OK will send you to a download page of one such browser"
    if confirm(msg)
      window.location = "http://google.com/chrome"
  $('#files').change(handleFileSelect)
  setProgress(0, 'Waiting for file selection.')

###
Utility Function to update the progressbar
###
setProgress = (percent, statusLabel) ->
  $(".percent").text(percent + "%").width(percent + "%")
  $("#progress_bar").removeClass().addClass("loading")
  $("#status").text statusLabel

###
# Handler for the file selection
###
handleFileSelect = (evt) ->
  # Handle older IE failing miserably
  if evt.target.files
    for f in evt.target.files
      uploadFile(f)
  else
    uploadFile($(this).val())


###
# Initializer for the upload, fetches required metadata from the server
###
uploadFile = (file, callback) ->
  setProgress 0, "Attempting to get metadata."
  $.getJSON("signput",
    { name: file.name.toString(), type: file.type.toString() },
    (urldata) ->
      setProgress 0, "Metadata received."
      x = uploadToS3 file, urldata.upload_url
      console.log "jqXHR", x
  )

###
Use a CORS call to upload the given file to S3. Assumes the url
parameter has been signed and is accessible for upload.
###

uploadToS3 = (file, url) ->
  $.ajax
    type: "PUT"
    url: url
    data: file

    contentType: file.type
    contentSize: file.size
    processData: false

    # Since jQuery doesn't yet know how to handle upload progress, do the setup
    # manually.
    xhr: ->
      xhr = $.ajaxSettings.xhr()
      if xhr.upload
        xhr.upload.addEventListener('progress', uploadProgress, false)
      else
        setProgress 50, "Browser doesn't support upload progress reporting"
      return xhr

    beforeSend: (xhr, settings) ->
      # This needs to be thought through.
      xhr.setRequestHeader "x-amz-acl", "public-read"

  .fail (e, text, msg) ->
    setProgress 0, "Upload failed: (#{text})#{msg}"

  .done ->
    setProgress 100, "Upload completed."

uploadProgress = (evt) ->
  console.log "hitting update progress", evt
  if evt.lengthComputable
    percentLoaded = Math.round((evt.loaded / evt.total) * 100)
    setProgress percentLoaded, (if percentLoaded is 100 then "Finalizing." else "Uploading.")
