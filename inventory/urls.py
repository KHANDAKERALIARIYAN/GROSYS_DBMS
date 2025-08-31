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
    path('product/<int:pk>/', views.product_detail, name='product_detail'),

    # Purchases & Sales
    path("purchases/", views.purchase_list, name="purchase_list"),
    path("products/<int:pk>/purchase/", views.purchase, name="purchase"),
    path("sales/", views.sale_list, name="sale_list"),
    path("products/<int:pk>/sale/", views.sale, name="sale"),

    # Supplier & Category
    path("suppliers/", views.supplier_list, name="supplier_list"),
    path("categories/", views.category_list, name="category_list"),
    path("categories/add/", views.category_add, name="category_add"),
    path("categories/<int:pk>/", views.category_detail, name="category_detail"),
    path("categories/<int:pk>/update/", views.category_update, name="category_update"),
    path("categories/<int:pk>/delete/", views.category_delete, name="category_delete"),

    path("suppliers/add/", views.supplier_create, name="supplier_create"),
    path("suppliers/<int:pk>/", views.supplier_detail, name="supplier_detail"),
    path("suppliers/<int:pk>/update/", views.supplier_update, name="supplier_update"),
    path("suppliers/<int:pk>/delete/", views.supplier_delete, name="supplier_delete"),
]
