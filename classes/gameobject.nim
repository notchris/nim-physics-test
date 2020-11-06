import ../physics/chipmunk
import csfml

type
  GameBodyKind* = enum
    bkRect,
    bkPolygon

type
  GameBody* = ref object
    id: int
    case kind: GameBodyKind
    of bkRect: width, height*: float
    of bkPolygon: points*: seq[Vect]
    x, y: float
    body: chipmunk.Body
    shape: chipmunk.PolyShape

var idx: int = 0;
proc generateId(): int =
  result = idx
  idx.inc

proc newRectBody(x, y, width, height: float): GameBody =
  result = GameBody(id: generateId(), kind: bkRect, x: x, y: y)
  result.body = newBody(50.0, momentForBox(50.0, width, height))
  result.shape = newBoxShape(result.body, width, height, 0.0)

  result.body.position = Vect(x: x, y: y)
  