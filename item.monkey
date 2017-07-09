' アイテムクラス
Class Item
	' X座標
	Field x
	' Y座標
	Field y
	' 表示状態 0:非表示 1:表示
	Field v
	' アイテム表示カウント
	Field c
	
	Method New()
		Self.v = 0
		Self.c = 0
	End
End
