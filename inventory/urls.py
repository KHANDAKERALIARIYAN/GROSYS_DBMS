from django.urls import path
from . import views

app_name = 'inventory'

urlpatterns = [
    path("", views.dashboard, name="dashboard"),

    # Products
    path("products/", views.product_list, name="product_list"),
    path("products/create/", views.product_create, name="product_create"),
    path("products/<int:pk>/update/", views.product_update, name="product_update"),
    path("products/<int:pk>/delete/", views.product_delete, name="product_delete"),

    # Purchases & Sales
    path("purchases/", views.purchase_list, name="purchase_list"),
    path("products/<int:pk>/purchase/", views.purchase, name="purchase"),
    path("sales/", views.sale_list, name="sale_list"),
    path("products/<int:pk>/sale/", views.sale, name="sale"),
]
