from django.db.models.signals import pre_save
from django.dispatch import receiver
from .models import Product

@receiver(pre_save, sender=Product)
def normalize_sku_and_quantity(sender, instance: Product, **kwargs):
    # Normalize SKU
    if instance.sku:
        instance.sku = instance.sku.strip().upper()
    # Guard against negative quantity
    if instance.quantity is None:
        instance.quantity = 0
    if instance.quantity < 0:
        instance.quantity = 0
