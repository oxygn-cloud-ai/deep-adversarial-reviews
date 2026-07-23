FROM python:3.12-slim
WORKDIR /gilded-rose
COPY original.py ./
CMD ["python", "-c", "from original import GildedRose, Item; items = [Item('foo', 0, 0)]; g = GildedRose(items); g.update_quality(); print('OK')"]