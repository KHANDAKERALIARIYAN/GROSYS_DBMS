from django.contrib import admin

from .models import Product, Supplier, Category

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'sku', 'quantity', 'price')
    search_fields = ('name', 'sku')
    list_editable = ('quantity', 'price')


@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'contact_person', 'phone', 'email')
    search_fields = ('name', 'contact_person', 'email')


