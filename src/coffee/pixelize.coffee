$ = jQuery
$.fn.extend {} =
  pixelize: (imageUrl) ->
    return @each () ->
      container = $(@)
      $.getImageData
        url: imageUrl
        success: (image) ->
          container.empty()
          canvas_el = $("<canvas id='canvas-profile' width='#{image.width-1}' height='#{image.height-1}'></canvas>")
          container.append canvas_el
          canvas = canvas_el.get(0).getContext('2d')
          canvas.drawImage(image, 0, 0, image.width, image.height)
          image_data = canvas.getImageData(0, 0, image.width, image.height)
          size = 4
          for w in [0..(image.width-1)] by size
            for h in [0..(image.height-1)] by size
              average = (image_data.data[((image.width*h)+w)*4] + image_data.data[((image.width*h)+w)*4+1] + image_data.data[((image.width*h)+w)*4+2]) / 3
              for i in [0..(size-1)]
                for j in [0..(size-1)]
                  unless w+j > image.width-1 or h+i > image.height-1
                    image_data.data[((image.width*(h+i))+w+j)*4] = average
                    image_data.data[((image.width*(h+i))+w+j)*4+1] = average + 20
                    image_data.data[((image.width*(h+i))+w+j)*4+2] = average

          canvas.putImageData(image_data, 0, 0)

        error: (xhr, text_status) ->
          console.log "Error loading profile image: #{text_status}"
