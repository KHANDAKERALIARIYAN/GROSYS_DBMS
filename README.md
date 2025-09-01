# GROSYS

GROSYS is a Django-based inventory management system designed for grocery stores. It allows users to manage products, suppliers, categories, purchases, and sales efficiently.

## Features
- Dashboard with product, unit, and inventory value overview
- Product management (add, update, delete, view)
- Supplier management (add, update, delete, view)
- Category management (add, update, delete, view)
- Purchase and sale tracking
- Low stock alerts
- Modern, responsive UI

## Technologies Used
- Python 3.12
- Django 4.2
- Oracle Database (via django.db.backends.oracle)
- HTML, CSS (custom styles)

## Setup Instructions
1. **Clone the repository:**
	```
	git clone https://github.com/KHANDAKERALIARIYAN/GROSYS_DBMS.git
	cd GROSYS_DBMS
	```
2. **Install dependencies:**
	```
	pip install -r requirements.txt
	```
3. **Configure your database:**
	- Update `invproj/settings.py` with your Oracle DB credentials.
4. **Apply migrations:**
	```
	python manage.py migrate
	```
5. **Run the development server:**
	```
	python manage.py runserver
	```
6. **Access the app:**
	- Open your browser and go to `http://127.0.0.1:8000/`

## Folder Structure
- `inventory/` - Main app with models, views, templates
- `invproj/` - Project settings and configuration
- `requirements.txt` - Python dependencies
- `manage.py` - Django management script

## Usage
- Use the navigation bar to access Products, Purchases, Sales, Suppliers, and Categories.
- Add, update, view, or delete records using the provided UI buttons.
- Dashboard displays key inventory metrics and low-stock alerts.

## License
This project is licensed under the MIT License.

## Author
KHANDAKER ALI ARIYAN , Nayef Wasit Siddiqui , Samiul Alim Auntor

