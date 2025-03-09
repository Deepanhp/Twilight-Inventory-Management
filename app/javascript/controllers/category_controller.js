import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subCategorySelect", "itemSelect"]

  loadSubCategories(event) {
    const categoryId = event.target.value
    if (categoryId === "") {
      this.clearSubCategories()
      this.clearItems()
      return
    }

    fetch(`/categories/${categoryId}/sub_categories`)
      .then(response => response.json())
      .then(data => {
        this.subCategorySelectTarget.innerHTML = '<option value="">Select Sub Category</option>'
        data.forEach(subCategory => {
          const option = new Option(subCategory.name, subCategory.id)
          this.subCategorySelectTarget.add(option)
        })
      })
  }

  loadItems(event) {
    const subCategoryId = event.target.value
    if (subCategoryId === "") {
      this.clearItems()
      return
    }

    fetch(`/sub_categories/${subCategoryId}/items`)
      .then(response => response.json())
      .then(data => {
        this.itemSelectTarget.innerHTML = '<option value="">Select Item</option>'
        data.forEach(item => {
          const option = new Option(item.name, item.id)
          this.itemSelectTarget.add(option)
        })
      })
  }

  clearSubCategories() {
    this.subCategorySelectTarget.innerHTML = '<option value="">Select Sub Category</option>'
  }

  clearItems() {
    this.itemSelectTarget.innerHTML = '<option value="">Select Item</option>'
  }
} 