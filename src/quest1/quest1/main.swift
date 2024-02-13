//
//  main.swift
//  quest1
//
//  Created by Knapptan on 02.02.2024.
//

import Foundation
import RealmSwift

class RecipeDataSource {
    @Published var realm: Realm?
    
    init() {
        do {
            self.realm = try Realm()
        } catch let error as NSError {
            print("Error initializing Realm:", error.localizedDescription)
        }
    }
    
    // Создание нового рецепта
    func CreateRecipe(recipe: Recipe) {
        do {
            try realm?.write {
                realm?.add(recipe)
                try! realm?.commitWrite()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // Получение всех рецептов из базы данных
    func ReadRecipes() -> [Recipe]? {
        return realm?.objects(Recipe.self).map { $0 }
    }
    
    // Обновление существующего рецепта по айди
    func UpdateRecipe(recipe: Recipe) {
        do {
            try realm?.write {
                realm?.create(Recipe.self, value: [
                    "_id": recipe.id,
                    "Name": recipe.Name,
                    "Steps": recipe.Steps,
                    "ImageName": recipe.ImageName
                ], update: .modified)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
        
    // Удаление рецепта
    func DeleteRecipe(recipe: Recipe) {
        do {
            try realm?.write {
                realm?.delete(recipe)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Поиск рецепта по названию
    func FindRecipeByName(_ name: String) -> Recipe? {
        // Используем предикат для фильтрации рецептов по названию
        let predicate = NSPredicate(format: "Name == %@", name)
        // Выполняем запрос к базе данных Realm и возвращаем первый найденный рецепт
        return realm?.objects(Recipe.self).filter(predicate).first
    }
    
}

class Recipe: Object {
    @Persisted (primaryKey: true) var id: ObjectId
    @Persisted var Name = ""
    @Persisted var Steps = ""
    @Persisted var ImageName = ""
    
    convenience init (_ name: String, _ steps: String, _ imageName: String) {
        self.init()
        self.id = ObjectId.generate()
        self.Name = name
        self.Steps = steps
        self.ImageName = imageName
    }
}

// Основное исполенение кода
func main(){
    // Создаем экземпляр для будущей БД
    let ds = RecipeDataSource()
     // Чистим
     try! ds.realm!.write {
         ds.realm!.deleteAll()
     }
     
    // Создаем рецепты
    let recipes = [
        Recipe("wok", "Make wok", "/wok.png"),
        Recipe("burger", "Make burger", "/burger.png"),
        Recipe("sup", "Make sup", "/sup.png"),
        Recipe("dish", "Make dish", "/dish.png"),
        Recipe("cake", "Make cake", "/cake.png")
    ]
    
    // Добавляем рецепты в БД
    recipes.forEach { ds.CreateRecipe(recipe: $0) }
    
    // Получение всех рецептов из базы данных
    print("All recipes\n")
    print(ds.ReadRecipes() ?? "nil")
    
    // Удаление первого элемента списка из БД
    if let firstRecipe = ds.ReadRecipes()?.first {
        ds.DeleteRecipe(recipe: firstRecipe)
    }
    
    // Вывод всего списка рецептов на экран
    print("\nAfter deletion\n")
    print(ds.ReadRecipes() ?? "nil")
    
    // Обновление названия первого элемента в списке
    if let firstRecipe = ds.ReadRecipes()?.first {
        var updatedRecipe = Recipe("wok", "Make wok", "/wok.png")
        updatedRecipe.Name = "Updated Name"
        updatedRecipe.id = firstRecipe.id
        ds.UpdateRecipe(recipe: updatedRecipe)
    }
    
    // Вывод всего списка рецептов на экран после обновления
    print("\nAfter update\n")
    print(ds.ReadRecipes() ?? "nil")
    
    // Поиск рецепта по названию
    print("\nSearch\n")
    let searchName = "sup"
    if let foundRecipe = ds.FindRecipeByName(searchName) {
        print("Found recipe with name '\(searchName)':", foundRecipe)
    } else {
        print("Recipe with name '\(searchName)' not found")
    }
    
    // На случай если нужно удалить бд
    //do {
    //    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    //    let realm = try Realm(configuration: configuration)
    //} catch {
    //    print("Error opening realm: \(error.localizedDescription)")
    //}
}

main()
