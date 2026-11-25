-- Dwelling type of a sale. Sales without any house/apartment get 'Terrain / autre'.
select * from (values
    ('Maison', 'House'),
    ('Appartement', 'Apartment'),
    ('Terrain / autre', 'Land / other')
) as t(property_type_key, property_type_label)
