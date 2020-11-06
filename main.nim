import 
  globals,
  physics/chipmunk,
  csfml, 
  math,
  random

randomize()

## Filters
const
  cBorder = 0b0001.BitMask
  cBall = 0b0010.BitMask
  cBox = 0b0100.BitMask

let
  FilterBorder = chipmunk.ShapeFilter(
    group: nil,
    categories: cBorder,
    mask: cBorder or cBall or cBox
  )
  FilterBall = chipmunk.ShapeFilter(
    group:nil,
    categories: cBall,
    mask: cBorder or cBall
  )
  FilterBox = chipmunk.ShapeFilter(
    group:nil,
    categories: cBox,
    mask: cBorder or cBox
  )

## Collision types
let
  ctBorder = cast[CollisionType](1)
  ctBall = cast[CollisionType](2)
  ctBox = cast[CollisionType](3)

## Types
type
  FixtureType = enum
    ftRect
    ftCircle

  Fixture = ref object
    fixtureType: FixtureType
    body: chipmunk.Body
    shape: chipmunk.Shape
    sprite: csfml.RectangleShape

  World = ref object
    world: Space
    spawn: Vect
    objects: seq[Fixture]


proc setColor(this: RectangleShape, color: Color) =
  this.fillColor = color

proc newWorld(): World =
  result = World()
  result.world = newSpace()
  result.world.gravity = Vect(x: 0, y:300.0)
  result.spawn = Vect(x: 100.0, y:100.0)
  result.objects = newSeq[Fixture]()

proc newRectObject(this: World, x: float, y: float, width: float, height: float, mass: float, isStatic: bool): Fixture =
  result = Fixture()
  result.fixtureType = ftRect

  ## Create the sprite for this game object
  result.sprite = newRectangleShape()
  result.sprite.size = Vector2f(x: width, y: height)
  result.sprite.origin = Vector2f(x: width/2, y: height/2)
  result.sprite.fillColor = White

  ## Create a dynamic or static body
  if isStatic:
    result.body = this.world.addBody(newStaticBody())
  else:
    result.body = this.world.addBody(newBody(mass, momentForBox(mass, width, height)))
  result.body.position = Vect(x: x, y: y)
  
  ## Create the shape for this body
  result.shape = this.world.addShape(newBoxShape(result.body, width, height, radius = 0.0))
  result.shape.filter = FilterBox
  result.shape.collisionType = ctBox


## Init Window
var window = newRenderWindow(
  videoMode(WINDOW_WIDTH, WINDOW_HEIGHT, 32), "Game", WindowStyle.Default
)
## Set framerate
window.framerateLimit = 60

## Create the world
var world = newWorld()

## Create the floor
var floor = world.newRectObject(WINDOW_WIDTH.float / 2f, WINDOW_HEIGHT.float - 30f, WINDOW_WIDTH.float, 30f, 50f, true)
floor.sprite.setColor(Color(r: 160, g: 160, b: 160, a: 255))
world.objects.add(floor)

## Create some random falling rects
var count: int = 0
let colors = [Red, Blue, Green, Yellow, Magenta, Cyan]

while count < 5:
  var rw = rand(50..90)
  var rh = rand(50..100)
  var rect = world.newRectObject(100.0 * count.float, 300f, rw.float, rh.float, 50f, false)
  rect.sprite.setColor(sample(colors))
  world.objects.add(rect)
  count.inc

## Create falling rect
var testRectA = world.newRectObject(WINDOW_WIDTH.float / 2.0, 100f, 100f, 100f, 50f, false)

## Add the rect to the world
world.objects.add(testRectA)


## Main loop
var event: Event
while window.open():
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      window.close()
      break
    elif event.kind == EventType.KeyPressed:
      if event.key.code == KeyCode.Escape:
        window.close()
        break
    elif event.kind == MouseButtonPressed:
      if $event.mouseButton.button == "Left":
        testRectA.body.velocity = Vect(x: 0, y: 0)
        testRectA.body.position = Vect(x: event.mouseButton.x.float, y: event.mouseButton.y.float)
      break
      
  world.world.step(1.0/60.0)
  window.clear(Black)
  for o in world.objects: 
    if o.fixtureType == ftRect:
        o.sprite.position = Vector2f(x: o.body.position.x.float, y: o.body.position.y.float)
        o.sprite.rotation = o.body.angle.radToDeg()
        window.draw(o.sprite)
    
  window.display()

## Cleanup on quit
for o in world.objects:
  o.body.destroy()
  o.sprite.destroy()

world.world.destroy()