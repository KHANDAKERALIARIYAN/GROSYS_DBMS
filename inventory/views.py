from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django import forms
from django.db import transaction
from django.db.models import Q, Sum, F
from .models import Product, Purchase, Sale


# ---------------------- Forms ----------------------
class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = ['name', 'sku', 'category', 'supplier', 'quantity', 'price']


class MovementForm(forms.Form):
    amount = forms.IntegerField(min_value=1, label='Quantity')
    note = forms.CharField(required=False)


# ---------------------- Views ----------------------
def product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk)
    return render(request, 'inventory/product_detail.html', {'product': product})
def dashboard(request):
    total_products = Product.objects.count()
    total_units = Product.objects.aggregate(total=Sum('quantity'))['total'] or 0
    inventory_value = Product.objects.aggregate(val=Sum(F('quantity') * F('price')))['val'] or 0
    low_stock = Product.objects.filter(quantity__lte=5).order_by('name')  # threshold

    context = {
        'total_products': total_products,
        'total_units': total_units,
        'inventory_value': inventory_value,
        'low_stock': low_stock,
    }
    return render(request, 'inventory/dashboard.html', context)


def product_list(request):
    q = request.GET.get('q', '').strip()
    qs = Product.objects.all().order_by('name')
    if q:
        qs = qs.filter(Q(name__icontains=q) | Q(sku__icontains=q))
    return render(request, 'inventory/product_list.html', {'products': qs, 'q': q})


def product_create(request):
    if request.method == 'POST':
        form = ProductForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Product created.')
            return redirect('inventory:product_list')
    else:
        form = ProductForm()
    return render(request, 'inventory/product_form.html', {'form': form})


def product_update(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        form = ProductForm(request.POST, instance=product)
        if form.is_valid():
            form.save()
            messages.success(request, 'Product updated.')
            return redirect('inventory:product_list')
    else:
        form = ProductForm(instance=product)
    return render(request, 'inventory/product_form.html', {'form': form, 'product': product})


def product_delete(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        product.delete()
        messages.success(request, 'Product deleted.')
        return redirect('inventory:product_list')
    return render(request, 'inventory/product_delete_confirm.html', {'product': product})


@transaction.atomic
def purchase(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        form = MovementForm(request.POST)
        if form.is_valid():
            product.quantity = (product.quantity or 0) + form.cleaned_data['amount']
            product.save()
            Purchase.objects.create(product=product, quantity=form.cleaned_data['amount'], price=product.price)
            messages.success(request, 'Stock increased.')
            return redirect('inventory:product_list')
    else:
        form = MovementForm()
    return render(request, 'inventory/purchase_form.html', {'form': form, 'product': product})


@transaction.atomic
def sale(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        form = MovementForm(request.POST)
        if form.is_valid():
            amount = form.cleaned_data['amount']
            if amount > (product.quantity or 0):
                form.add_error('amount', 'Insufficient stock')
            else:
                product.quantity = product.quantity - amount
                product.save()
                Sale.objects.create(product=product, quantity=amount, price=product.price)
                messages.success(request, 'Stock reduced.')
                return redirect('inventory:product_list')
    else:
        form = MovementForm()
    return render(request, 'inventory/sale_form.html', {'form': form, 'product': product})


def purchase_list(request):
    purchases = Purchase.objects.all().order_by("-created_at")
    return render(request, "inventory/purchase_list.html", {"purchases": purchases})


def sale_list(request):
    sales = Sale.objects.all().order_by("-created_at")
    return render(request, "inventory/sale_list.html", {"sales": sales})
