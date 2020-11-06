import physics/chipmunk

type
    Body* = ref object
        body: chipmunk.Body
        shape: chipmunk.Shape
        