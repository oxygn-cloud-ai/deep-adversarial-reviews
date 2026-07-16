FROM python:3.12-slim
WORKDIR /gilded-rose
COPY gilded_rose.py original.py ./
CMD ["python", "-c", "from gilded_rose import GildedRose, Item; items = [Item('foo', 0, 0)]; g = GildedRose(items); g.update_quality(); print('OK')"]
