// PetGameScene.swift

import SpriteKit

enum PetMood: String {
    case idle, happy, hungry, sleepy, angry
}

class PetGameScene: SKScene {
    private var petSprite: SKSpriteNode!
    private var currentMood: PetMood = .idle

    private let petZPosition: CGFloat = 10

    override func sceneDidLoad() {
        backgroundColor = .white
        self.scaleMode = .aspectFit
        setupScene()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🕐 Forcing idle mood to start animation")
            self.setMood(.idle, force: true)
        }
    }

    private func setupScene() {
        let atlas = SKTextureAtlas(named: "PetIdle")
        let defaultTexture = atlas.textureNamed("frame1.png")
        petSprite = SKSpriteNode(texture: defaultTexture)
        petSprite.setScale(0.01)
        petSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        petSprite.zPosition = petZPosition
        addChild(petSprite)
    }

    func setMood(_ mood: PetMood, force: Bool = false) {
        guard force || mood != currentMood else { return }

        print("🐾 Changing mood to: \(mood.rawValue)")
        currentMood = mood
        petSprite.removeAllActions()

        let animation = animationForMood(mood)
        petSprite.run(SKAction.repeatForever(animation), withKey: "moodAnimation")
    }

    func showFeedEffect() {
        print("💡 Feed effect triggered (implement me when assets are ready!)")
    }

    func showPlayEffect() {
        print("💡 Play effect triggered (implement me when assets are ready!)")
    }

    func showCleanEffect() {
        print("💡 Clean effect triggered (implement me when assets are ready!)")
    }

    func showSleepEffect() {
        print("💡 Sleep effect triggered (implement me when assets are ready!)")
    }

    private func animationForMood(_ mood: PetMood) -> SKAction {
        let atlasName = "Pet\(mood.rawValue.capitalized)"
        let atlas = SKTextureAtlas(named: atlasName)

        print("📦 Loading atlas: \(atlasName)")
        print("🎨 Found textures: \(atlas.textureNames)")

        let sortedTextureNames = atlas.textureNames.sorted { name1, name2 in
            let num1 = Int(name1.filter(\.isNumber)) ?? 0
            let num2 = Int(name2.filter(\.isNumber)) ?? 0
            return num1 < num2
        }

        let textures = sortedTextureNames.map { atlas.textureNamed($0) }

        guard !textures.isEmpty else {
            print("⚠️ No textures found in \(atlasName)")
            return SKAction.wait(forDuration: 1.0)
        }

        return SKAction.animate(with: textures, timePerFrame: 0.1, resize: false, restore: false)
    }
}
