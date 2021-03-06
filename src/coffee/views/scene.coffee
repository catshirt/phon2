define [
  'jquery',
  'underscore',
  'three',
  'tween',
  'graphics/utils'
], ($, _, THREE, TWEEN, ThreeUtils) ->

  # the `stage` view is responsible for setting up
  # the 3js stage and camera and re-rendering the scene.
  class extends THREE.Scene

    # create stage, bind resizing functions
    constructor: (matrixView) ->
      THREE.Scene.apply @
      @matrixView = matrixView
      @renderer = new THREE.CanvasRenderer()
      @camera = new THREE.PerspectiveCamera(100, 1, 1, 1000)
      @el = @renderer.domElement

      # manage canvas size
      $(window).on 'resize', do =>
        width = window.innerWidth
        height = window.innerHeight

        @camera.aspect = width / height
        @camera.updateProjectionMatrix()
        @renderer.setSize width, height
        arguments.callee

      # delegate clicks to specific meshes
      $(@el).on 'mousedown', _.bind(@onMousedown, @)

      # add matrixView object to scene
      @add(matrixView.render())

      # begin main scene animation
      do =>
        TWEEN.update()
        @renderer.render @, @camera
        webkitRequestAnimationFrame arguments.callee

      # centers the camera on an object
      center = ThreeUtils.computeObject3DCenter(matrixView)
      @camera.position.x = center.x
      @camera.position.y = center.y
      @camera.position.z = 300

    getClickedMesh: (e) ->
      ThreeUtils.computeClickedMesh($(@el), e, @camera, @matrixView)

    onMousedown: (e) ->
      mesh = @getClickedMesh(e)
      e.preventDefault()
      mesh?.onMousedown(e)
      @matrixView.onMousedown(e, mesh)