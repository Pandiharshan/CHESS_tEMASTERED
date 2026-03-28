import trimesh
import trimesh.creation
import numpy as np
import os

def create_pawn():
    # Base cylinder
    base = trimesh.creation.cylinder(radius=0.4, height=0.2)
    # Body cone/cylinder
    body = trimesh.creation.cone(radius=0.3, height=0.8)
    body.apply_translation([0, 0, 0.4])
    # Head sphere
    head = trimesh.creation.icosphere(radius=0.25)
    head.apply_translation([0, 0, 1.2])

    pawn = trimesh.util.concatenate([base, body, head])
    
    # We color it later in flutter but can give a default material
    # Center and scale to 1 unit
    pawn.apply_translation(-pawn.center_mass)
    pawn.apply_scale(1.0 / pawn.scale)
    
    os.makedirs('assets', exist_ok=True)
    pawn.export('assets/pawn.glb')

if __name__ == '__main__':
    create_pawn()
