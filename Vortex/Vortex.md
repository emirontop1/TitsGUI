--// Say wallahi bismillah bro...
local PremiumLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/emirontop1/P/refs/heads/main/Src/PremiumLib.lua"))()
-- veya: local PremiumLib = require(path.to.PremiumLib)

local Window = PremiumLib.CreateWindow(
	"Vortex Hub",
	"v1.0.0",
	"VORTEX",
	"Yükleniyor, lütfen bekleyin..."
)

local MainTab = Window:CreateTab("Ana Sayfa")

------------------------------------------------------------
-- Mevcut elementler (değişmedi)
------------------------------------------------------------
MainTab:CreateSection("Genel")

MainTab:CreateButton("Test Butonu", function()
	print("Butona tıklandı!")
end)

MainTab:CreateToggle("Otomatik Farm", false, function(state)
	print("Toggle durumu:", state)
end)

MainTab:CreateTextBox("Kullanıcı adı gir...", "", function(text)
	print("Girilen metin:", text)
end)

MainTab:CreateParagraph("Bilgi", "Bu kütüphane PC ve mobil cihazlarda tam destekle çalışır.")

------------------------------------------------------------
-- YENİ: Dropdown (Tek Seçimli)
------------------------------------------------------------
MainTab:CreateSection("Yeni Elementler")

local SilahDropdown = MainTab:CreateDropdown(
	"Silah Seç",
	{"AK-47", "M4A1", "AWP", "Desert Eagle"},
	"AK-47",
	function(selected)
		print("Seçilen silah:", selected)
	end
)
-- Dışarıdan değiştirmek istersen:
-- SilahDropdown:SetValue("AWP")
-- SilahDropdown:SetOptions({"Yeni Silah 1", "Yeni Silah 2"})

------------------------------------------------------------
-- YENİ: MultiDropdown (Çoklu Seçim)
------------------------------------------------------------
local OzellikMultiDD = MainTab:CreateMultiDropdown(
	"Aktif Özellikler",
	{"ESP", "Aimbot", "Speedhack", "Fly", "Noclip"},
	{"ESP"}, -- varsayılan seçili olanlar
	function(selectedTable)
		for name, isOn in pairs(selectedTable) do
			if isOn then print(name, "aktif") end
		end
	end
)

------------------------------------------------------------
-- YENİ: Slider
------------------------------------------------------------
local HizSlider = MainTab:CreateSlider(
	"Yürüme Hızı",
	16,    -- min
	200,   -- max
	16,    -- varsayılan
	function(value)
		print("Hız ayarlandı:", value)
		-- Örnek: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
	end
)
-- HizSlider:SetValue(100)

------------------------------------------------------------
-- YENİ: ColorPicker
------------------------------------------------------------
local ESPRenk = MainTab:CreateColorPicker(
	"ESP Rengi",
	Color3.fromRGB(255, 0, 0),
	function(color)
		print("Yeni renk:", color)
	end
)
-- ESPRenk:SetValue(Color3.fromRGB(0, 255, 0))

------------------------------------------------------------
-- YENİ: Keybind
------------------------------------------------------------
local MenuTusu = MainTab:CreateKeybind(
	"Menüyü Aç/Kapat",
	Enum.KeyCode.RightShift,
	function(key)
		print("Yeni tuş atandı:", key.Name)
	end
)

------------------------------------------------------------
-- YENİ: Notify (Toast Bildirimi)
------------------------------------------------------------
-- self:Notify(başlık, içerik, süre_saniye, tip)
-- tip: "Info" | "Success" | "Warning" | "Error"

MainTab:CreateButton("Bildirim Gönder (Success)", function()
	Window:Notify("Başarılı", "Script başarıyla yüklendi!", 4, "Success")
end)

MainTab:CreateButton("Bildirim Gönder (Error)", function()
	Window:Notify("Hata", "Bağlantı kurulamadı, tekrar deneniyor...", 4, "Error")
end)

MainTab:CreateButton("Bildirim Gönder (Warning)", function()
	Window:Notify("Uyarı", "Bu işlem geri alınamaz.", 5, "Warning")
end)

-- Otomatik açılış bildirimi örneği
Window:Notify("Hoş Geldin", "Vortex Hub başarıyla başlatıldı.", 3, "Info")

------------------------------------------------------------
-- SubTab içinde de aynı elementler kullanılabilir
------------------------------------------------------------
local SubContainer = MainTab:CreateSubTabContainer()
local AyarlarSub = SubContainer:CreateSubTab("Gelişmiş Ayarlar")

AyarlarSub:CreateSlider("FOV", 60, 120, 90, function(v) print("FOV:", v) end)
AyarlarSub:CreateDropdown("Tema", {"Koyu", "Açık"}, "Koyu", function(v) print(v) end)
AyarlarSub:CreateColorPicker("Vurgu Rengi", Color3.fromRGB(255,255,255), function(c) print(c) end)


