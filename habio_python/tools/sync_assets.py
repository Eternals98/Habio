"""
Simple asset synchronizer for Habio client.
Use this script during development to copy root assets into the Flet client assets folder so the client can load images from assets/images/...
"""
import os
import shutil

ROOT_ASSETS = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'images'))
CLIENT_ASSETS = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'images'))

COPY_SUBDIRS = ['pets', 'room_icons']


def sync():
    os.makedirs(CLIENT_ASSETS, exist_ok=True)
    for sub in COPY_SUBDIRS:
        src = os.path.join(ROOT_ASSETS, sub)
        dst = os.path.join(CLIENT_ASSETS, sub)
        if not os.path.exists(src):
            print(f"Source subdir not found: {src}")
            continue
        print(f"Syncing {src} -> {dst}")
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
    print("Done. Client assets synced.")


if __name__ == '__main__':
    sync()