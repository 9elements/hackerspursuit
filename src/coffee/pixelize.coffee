$ = jQuery
$.fn.extend {} =
  pixelize: (width, height) ->
    canvas = @.get(0).getContext('2d')
    image_data = canvas.getImageData(0, 0, width, height)
    size = 4
    for w in [0..(width-1)] by size
      for h in [0..(height-1)] by size
        average = (image_data.data[((width*h)+w)*4] + image_data.data[((width*h)+w)*4+1] + image_data.data[((width*h)+w)*4+2]) / 3
        for i in [0..(size-1)]
          for j in [0..(size-1)]
            unless w+j > width-1 or h+i > height-1
              image_data.data[((width*(h+i))+w+j)*4] = average
              image_data.data[((width*(h+i))+w+j)*4+1] = average + 20
              image_data.data[((width*(h+i))+w+j)*4+2] = average

    canvas.putImageData(image_data, 0, 0)