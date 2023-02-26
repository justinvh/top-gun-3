"""
Converts a Tiled map to the binary format used by the game.
See engine/map.asm for the format specification.
"""
import pathlib
import argparse
import struct
import pytmx
import logging

logger = logging.getLogger(__name__)

class Exporter:

    # This field is specifically mapped to the tileset struct in the game.
    fields = []

    def __init__(self):
        """
        Initialize the tileset with default values.
        """
        self.data = []
        for name, fmt in self.fields:
            setattr(self, name, 0)

    def append(self, obj) -> None:
        """
        Append data to the end of the struct.
        """
        self.data.append(obj)

    def pack(self) -> bytes:
        """
        Pack the object into a binary string based on the fields.
        Appends the data as bytes to the end of the string.
        """
        # Initially create the pack string with the fields.
        pack_str = ''.join(fmt for _, fmt in self.fields)

        # Pack the data from the children.
        packed_data = bytearray([])
        for obj in self.data:
            if isinstance(obj, Exporter):
                packed_data.extend(obj.pack())
            else:
                packed_data.extend(bytearray([obj]))

        # Add the data to the end of the pack string.
        pack_str += f'{len(packed_data)}B'
        
        all_data = []
        for name, width in self.fields:
            obj = getattr(self, name)
            if isinstance(obj, bytearray):
                width = int(width.replace('B', ''))
                all_data.extend(obj)
                if len(obj) < width:
                    for i in range(width - len(obj)):
                        all_data.append(0)
            else:
                all_data.append(obj)
        all_data.extend(packed_data)

        return struct.pack(pack_str, *all_data)

    def num_bytes(self) -> int:
        """
        Return the number of bytes that will be written to the file.
        """
        return len(self.pack())


class Tile(Exporter):
    fields = [
        ('id', 'B'),
        ('x', 'H'),
        ('y', 'H'),
    ]

    def __init__(self, pk, x, y):
        super().__init__()
        self.id = pk
        self.x = x
        self.y = y


class SpriteSheet(Exporter):
    fields = [
        ('magic', '3B'),
        ('bpp', 'B'),
        ('width', 'B'),
        ('height', 'B'),
        ('num_rows', 'B'),
        ('num_cols', 'B'),
    ]

class Palette(Exporter):
    fields = [
        ('magic', '3B'),
        ('num_colors', 'B'),
    ]


class Map(Exporter):
    fields = [
        ('magic', '3B'),
        ('version', 'B'),
        ('name', '16B'),
        ('num_tiles', 'H'),
        ('num_objects', 'H'),
        ('tile_width', 'B'),
        ('tile_height', 'B'),
        ('height', 'B'),
        ('width', 'B'),
        ('tile_offset', 'H'),
        ('sprite_offset', 'H'),
        ('palette_offset', 'H'),
        ('object_offset', 'H'),
    ]

    def __init__(self, tmx_map):
        super().__init__()
        self.load(tmx_map)

    def load(self, tmx_map):
        """
        Loads a TMX map and converts it to the binary format.
        """
        # Set the magic number and version.
        self.magic = bytearray(b'TMX')
        self.version = 1

        tiled_map = pytmx.TiledMap(tmx_map, allow_duplicate_names=True, load_all_tiles=True)

        # Set the common map properties.
        self.name = bytearray(tiled_map.name.encode('ascii'))
        self.tile_width = tiled_map.tilewidth
        self.tile_height = tiled_map.tileheight
        self.width = tiled_map.width
        self.height = tiled_map.height

        # (HACK): Tile offset is fixed by field offset in the map struct.
        self.tile_offset = sum(struct.calcsize(fmt) for _, fmt in self.fields[:-4])

        # This will be updated as each tile is added
        self.sprite_offset = self.tile_offset

        # (HACK): Not supporting multiple layers
        layer = tiled_map.layers[0]

        # (HACK): Not support multiple sprite sheets
        sprite_sheet = None

        # Load all non-zero tile from the layer.
        for x, y, gid in layer.iter_data():
            if gid == 0:
                continue

            # Add a unique tile (not a gid=0 tile)
            x *= self.tile_width
            y *= self.tile_height

            # Add the tile and increment the counter tracking
            tile = Tile(x, y, gid)
            self.append(tile)
            self.num_tiles += 1

            # Extract the sprite sheet referenced by the tile gid
            sprite_sheet = pathlib.Path(layer.parent.images[gid][0])

            # Update the sprite offset for data tracking
            self.sprite_offset += tile.num_bytes()

        # Update the palette offset for data tracking
        self.palette_offset = self.sprite_offset

        # Get the sprite sheet and load the palette.
        sprite = SpriteSheet()
        sprite.magic = bytearray(b'4BPP')
        sprite.bpp = 4
        sprite.width = 8
        sprite.height = 8
        sprite.num_rows = 3
        sprite.num_cols = 3
        path = sprite_sheet.with_suffix('.bin')
        with open(path, 'rb') as fd:
            data_4bpp = fd.read()
            sprite.data.extend(data_4bpp)
        self.append(sprite)

        # Update the palette offset for data tracking
        self.palette_offset += sprite.num_bytes()

        # Load color data for the sprite sheet.
        palette = Palette()
        palette.magic = bytearray(b'PAL')
        palette.num_colors = 16
        path = sprite_sheet.with_suffix('.pal')
        self.object_offset = self.palette_offset
        with open(path, 'rb') as fd:
            data_pal = fd.read()
            palette.data.extend(data_pal)
        self.append(palette)

        # Update the object offset for data tracking
        self.object_offset += palette.num_bytes()


def main():
    """
    Load a Tiled map and export it to a binary file that can be
    loaded by the game.
    """
    args = argparse.ArgumentParser()
    args.add_argument('input')
    args.add_argument('output')
    parsed = args.parse_args()

    # Create the map and export it.
    tile_map = Map(parsed.input)
    with open(parsed.output, 'wb') as f:
        f.write(tile_map.pack())
    
if __name__ == '__main__':
    main()