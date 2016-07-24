' 操作キャラクタークラス
Class Actor
	' 向いている方向
	' 0:左 1;右
	Field d
	' X座標
	Field x
	' Y座標
	Field y
	' アニメーション
	Field a
	' ステート（状態）
	Field s
	' 射撃中
	Field shot
	' 装備武器
	' 0: 拳銃 1: ショットガン 2: マチェット
	Field equip
	' ショットガンの弾数
	Field ammo
	' 飛び散りX座標
	Field xs:Int[36]
	' 飛び散りY座標
	Field ys:Int[36]
	' 飛び散り血液X座標
	Field bxs:Int[36]
	' 飛び散り血液Y座標
	Field bys:Int[36]
	' 飛び散りX座標速度
	Field xspeed:Int[36]
	' 飛び散りY座標速度
	Field yspeed:Int[36]
	
	Method New()
		equip = 1
		ammo = 8
		For Local i = 0 To 35
			xspeed[i] = Rnd(-10, 10)
			yspeed[i] = Rnd(-10, 10)
		Next
	End
	
	Method SetUp()
		Local n = 0
		Local j = 0
		
		For Local i = 0 To 35
			xs[i] = Self.x + n * 8
			ys[i] = Self.y + j
			n = n + 1
			If n > 5
				n = 0
				j = j + 8
			End
			bxs[i] = xs[i]
			bys[i] = ys[i]
		Next
	End
End