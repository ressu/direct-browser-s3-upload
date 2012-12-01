$ -> 
  $('#files').change(handleFileSelect)
  setProgress(0, 'Waiting for upload.')

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
createCORSRequest = (method, url) ->
  xhr = new XMLHttpRequest()
  if "withCredentials" of xhr
    xhr.open method, url, true
  else unless typeof XDomainRequest is "undefined"
    xhr = new XDomainRequest()
    xhr.open method, url
  else
    return null
  return xhr

uploadToS3 = (file, url) ->
  xhr = createCORSRequest("PUT", url)
  unless xhr
    setProgress 0, "CORS not supported"
  else
    xhr.onload = ->
      if xhr.status is 200
        setProgress 100, "Upload completed."
      else
        setProgress 0, "Upload error: " + xhr.status

    xhr.onerror = ->
      setProgress 0, "XHR error."

    xhr.upload.onprogress = (e) ->
      if e.lengthComputable
        percentLoaded = Math.round((e.loaded / e.total) * 100)
        setProgress percentLoaded, (if percentLoaded is 100 then "Finalizing." else "Uploading.")

    xhr.setRequestHeader "Content-Type", file.type
    xhr.setRequestHeader "x-amz-acl", "public-read"
    xhr.send file

