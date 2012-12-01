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
  files = evt.target.files
  for f in files
    uploadFile(f)

###
# Initializer for the upload, fetches required metadata from the server
###
uploadFile = (file, callback) ->
  setProgress 0, "Attempting to get metadata."
  $.getJSON("signput",
    { name: file.name.toString(), type: file.type.toString() },
    (urldata) ->
      setProgress 0, "Metadata received."
      uploadToS3 file, urldata.upload_url
  )

###
Use a CORS call to upload the given file to S3. Assumes the url
parameter has been signed and is accessible for upload.
###

uploadToS3 = (file, url) ->
  # Make the PUT request.
  $.ajax
    type: "PUT"
    url: url
    # This needs to be thought through.
    # xhr.setRequestHeader "x-amz-acl", "public-read"
    data: file

    contentType: file.type
    processData: false

    error: (e, text, msg) ->
      console.log "ERROR:", e
      setProgress 0, "Upload failed: (#{text})#{msg}"

    success: ->
      setProgress 100, "Upload completed."

    beforeSend: (xhr, settings) ->
      xhr.upload.onProgress(updateProgress) if xhr.upload
      xhr.setRequestHeader "x-amz-acl", "public-read"

updateProgress = (e) ->
  if e.lengthComputable
    percentLoaded = Math.round((e.loaded / e.total) * 100)
    setProgress percentLoaded, (if percentLoaded is 100 then "Finalizing." else "Uploading.")
