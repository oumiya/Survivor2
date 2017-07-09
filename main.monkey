Import mojo
Import mojo.input
Import monkey.math
Import actor
Import zombie
Import item

Class Game Extends App
	Field map:Image
	Field chip:Image
	Field scene#
	Field score#
	Field actor:Actor
	Field counter:Int
	Field handgun:Sound
	Field shotgun:Sound
	Field doubleKill:Sound
	Field tripleKill:Sound
	Field multiKill:Sound
	Field roar:Sound
	Field zombies:=New Zombie[200]
	Field zombieDie1:Image
	Field zombieDie2:Image
	Field actorDie1:Image
	Field actorDie2:Image
	Field items:=New Item[5]
	Field itemidx#
	Field blood:Image
	Field dieCount
	Field shout:Sound
	Field numbers:Image
	
	Method OnCreate()
		map=LoadImage("image/map.png")
		chip=LoadImage("image/survivor2.png", 48, 48, 100)
		zombieDie1=LoadImage("image/zombie0.png", 8, 8, 36)
		zombieDie2=LoadImage("image/zombie1.png", 8, 8, 36)
		actorDie1=LoadImage("image/player0.png", 8, 8, 36)
		actorDie2=LoadImage("image/player1.png", 8, 8, 36)
		blood=LoadImage("image/blood.png")
		numbers=LoadImage("image/number.png", 24, 48, 10)
		handgun=LoadSound("audio/se/handgun.wav")
		shotgun=LoadSound("audio/se/shotgun.wav")
		roar=LoadSound("audio/se/zombie.wav")
		shout=LoadSound("audio/se/gameover.wav")
		doubleKill=LoadSound("audio/se/doublekill.wav")
		tripleKill=LoadSound("audio/se/triplekill.wav")
		multiKill=LoadSound("audio/se/multikill.wav")
		counter = 0
		PlayMusic("audio/bgm/battle.ogg", 1)
		Init()
	End
	
	Method Init()
		Seed = GetDate[5]
		SetUpdateRate(60)
		score = 0
		scene = 1
		actor = New Actor
		actor.a = 3
		actor.d = 1
		actor.shot = 0
		For Local i = 0 To 199
			zombies[i] = New Zombie
			zombies[i].d = 0
			zombies[i].x = 0
			zombies[i].y = 0			
			zombies[i].a = 10
			zombies[i].c = Rnd(1, 10)
			zombies[i].s = 0
			zombies[i].SetUp
		Next
		For Local i = 0 To 199
			Local dup = True
			
			Repeat
				dup = True
				zombies[i].x = Rnd(480, 6192)
				zombies[i].y = Rnd(192, 432)
				
				' 他のゾンビにめりこんだら座標を戻す
				For Local n = 0 To 199
					If i <> n
						If HitBox(zombies[i].x, zombies[i].y, zombies[i].x+32, zombies[i].y+32, zombies[n].x, zombies[n].y, zombies[n].x+32, zombies[n].y+32)
							dup = False
							Exit
						End
					End
				Next
				
				If dup
					Exit
				End
			Forever
			zombies[i].SetUp
		Next
		
		' アイテムの初期化
		itemidx = 0
		For Local i = 0 To 4
			items[i] = New Item
			items[i].x = 0
			items[i].y = 0
		Next
	End
	
	Method OnUpdate()
		counter = counter + 1
		If scene = 1
			' スペースキーかZキーが押されるまでタイトル画面を表示する
			If KeyHit(KEY_SPACE) Or KeyHit(KEY_Z)
				actor.x = 20
				actor.y = 202 
				scene = 2
				Return
			End
		End
		If scene = 2
			actor.s = 0
			actor.shot = actor.shot - 1
			If actor.shot < 0
				actor.shot = 0
			End
			' 十字キーで動き、スペースキーかZキーで射撃
			' 射撃中は動けないよ
			If actor.shot <= 0
				If KeyDown(KEY_LEFT)
					actor.d = 0
					actor.x = actor.x - 4
					If actor.x < 0
						actor.x = 0
					End
					actor.s = 1
				End
				
				If KeyDown(KEY_RIGHT)
					actor.d = 1
					actor.x = actor.x + 4
					actor.s = 1
				End
				
				If KeyDown(KEY_UP)
					actor.y = actor.y - 4
					If actor.y < 166
						actor.y = 166
					End
					actor.s = 1
				End
				
				If KeyDown(KEY_DOWN)
					actor.y = actor.y + 4
					If actor.y > 430
						actor.y = 430
					End
					actor.s = 1
				End
			End
			
			If KeyHit(KEY_Z) Or KeyHit(KEY_SPACE)
				If actor.shot = 0
					Local killCount = 0
					If actor.equip = 0
						PlaySound(handgun)
						actor.shot = 3
						' ゾンビの当たり判定
						Local px = actor.x + 24
						Local py = actor.y + 25
						Local qx = 0
						Local qy = py
						If actor.d = 0
							qx = px - 160
						Else
							qx = px + 160
						End
						
						For Local i = 0 To 199
							If zombies[i].s = 0
								If ZombieHit(zombies[i], px, py, qx, qy)
									zombies[i].s = 1
									PlaySound(roar, 1)
									killCount = killCount + 1
									
									Local drop = Rnd(1, 200)
									If drop > 150
										items[itemidx].x = zombies[i].x
										items[itemidx].y = zombies[i].y
										items[itemidx].v = 1
										items[itemidx].c = 300
										itemidx = itemidx + 1
										If itemidx > 4
											itemidx = 0
										End
									End
								End
							End
						Next
					Elseif actor.equip = 1
						PlaySound(shotgun)
						actor.shot = 20
						' ゾンビの当たり判定
						For Local i = 0 To 199
							If zombies[i].s = 0
								If actor.d = 0
									If HitBox(actor.x - 196, actor.y - 64, actor.x, actor.y + 64, zombies[i].x, zombies[i].y, zombies[i].x + 48, zombies[i].y + 48)
										zombies[i].s = 1
										PlaySound(roar, 1)
										killCount = killCount + 1
										Local drop = Rnd(1, 200)
									
										If drop > 190
											items[itemidx].x = zombies[i].x
											items[itemidx].y = zombies[i].y
											items[itemidx].v = 1
											items[itemidx].c = 300
											itemidx = itemidx + 1
											If itemidx > 4
												itemidx = 0
											End
										End
									End
								Else
									If HitBox(actor.x, actor.y - 64, actor.x + 196, actor.y + 64, zombies[i].x, zombies[i].y, zombies[i].x + 48, zombies[i].y + 48)
										zombies[i].s = 1
										PlaySound(roar, 1)
										killCount = killCount + 1
										Local drop = Rnd(1, 200)
									
										If drop > 190
											items[itemidx].x = zombies[i].x
											items[itemidx].y = zombies[i].y
											items[itemidx].v = 1
											items[itemidx].c = 300
											itemidx = itemidx + 1
											If itemidx > 4
												itemidx = 0
											End
										End
									End
								End
							End
						Next
						
						actor.ammo = actor.ammo - 1
						If actor.ammo < 1
							actor.equip = 0
						End
					End
					
					' キルカウントのサウンド
					If killCount = 2
						PlaySound(doubleKill, 2)
						score = score + 250
					Elseif killCount = 3
						PlaySound(tripleKill, 2)
						score = score + 500
					Elseif killCount > 3
						PlaySound(multiKill, 2)
						score = score + 2000
					Elseif killCount = 1
						score = score + 50
					End
				End
			End
			
			If actor.s = 1
				If actor.d = 0
					If actor.a >= 3
						actor.a = 0
					End
					If counter Mod 12 = 0
						If actor.a = 0 Or actor.a = 2
							actor.a = 1
						Else
							actor.a = 2
						End
					End
				Else
					If actor.a < 3
						actor.a = 3
					End
					If counter Mod 12 = 0
						If actor.a = 3 Or actor.a = 5
							actor.a = 4
						Else
							actor.a = 5
						End
					End
				End
			Else
				If actor.d = 0
					actor.a = 0
				Else
					actor.a = 3
				End
			End
			
			If actor.x > 6212
				scene = 5
				dieCount = 0
				StopMusic()
				PlayMusic("audio/bgm/ending.ogg", 1)
			End
			
			' ゾンビ
			For Local i = 0 To 199
				' ゾンビと主人公の当たり判定
				If zombies[i].s = 0
					If HitBox(zombies[i].x, zombies[i].y, zombies[i].x+32, zombies[i].y+32, actor.x + 16, actor.y+16, actor.x+34, actor.y+34)
						dieCount = 0
						scene = 3
						actor.SetUp
						PlaySound(shout)
					End
				End
				
				' ゾンビ近寄ってくる
				Local distance = Distance(actor.x, actor.y, zombies[i].x, zombies[i].y)
				Local ox = 0
				Local oy = 0
				If zombies[i].s = 0 And distance < 200
					ox = zombies[i].x
					oy = zombies[i].y
					
					If zombies[i].x > actor.x
						zombies[i].x = zombies[i].x - 2
						zombies[i].d = 0
					End
					If zombies[i].x < actor.x
						zombies[i].x = zombies[i].x + 2
						zombies[i].d = 1
					End
					If zombies[i].y > actor.y
						zombies[i].y = zombies[i].y - 2
					End
					If zombies[i].y < actor.y
						zombies[i].y = zombies[i].y + 2
					End
				Else
					If zombies[i].s = 0
						ox = zombies[i].x
						oy = zombies[i].y
						
						' ゾンビランダムウォーク
						If zombies[i].c Mod 60 = 0
							zombies[i].rd = Rnd(1, 5)
						End
						
						If zombies[i].rd = 1
							zombies[i].x = zombies[i].x + 1
							If zombies[i].x > 6192
								zombies[i].x = 6192
							End
						End
						If zombies[i].rd = 2
							zombies[i].x = zombies[i].x - 1
							If zombies[i].x < 0
								zombies[i].x = 0
							End
						End
						If zombies[i].rd = 3
							zombies[i].y = zombies[i].y + 1
							If zombies[i].y > 432
								zombies[i].y = 432
							End
						End
						If zombies[i].rd = 4
							zombies[i].y = zombies[i].y - 1
							If zombies[i].y < 166
								zombies[i].y = 166
							End
						End
					End
				End
				
				' 他のゾンビにめりこんだら座標を戻す
				For Local n = 0 To 199
					If i <> n
						If zombies[n].s = 0 And zombies[i].s = 0
							If HitBox(zombies[i].x, zombies[i].y, zombies[i].x+32, zombies[i].y+32, zombies[n].x, zombies[n].y, zombies[n].x+32, zombies[n].y+32)
								zombies[i].x = ox
								zombies[i].y = oy
							End
						End
					End
				Next
				
				If zombies[i].s = 0
					zombies[i].SetUp
				End
				
				' ゾンビ破裂中
				If zombies[i].s = 1
					For Local j = 0 To 35
						If zombies[i].ys[j] < zombies[i].y + 48
							zombies[i].bxs[j] = zombies[i].xs[j]
							zombies[i].bys[j] = zombies[i].ys[j]
							zombies[i].xs[j] = zombies[i].xs[j] + zombies[i].xspeed[j]
							zombies[i].ys[j] = zombies[i].ys[j] + zombies[i].yspeed[j]
							zombies[i].yspeed[j] = zombies[i].yspeed[j] + 2
						End
					Next
				End
			Next
			
			' アイテム
			For Local i = 0 To 4
				If items[i].v = 1
					items[i].c = items[i].c - 1
					If items[i].c <= 0
						items[i].c = 0
						items[i].v = 0
					End
					' アイテムの当たり判定
					If HitBox(items[i].x, items[i].y, items[i].x+48, items[i].y+48, actor.x + 16, actor.y+16, actor.x+34, actor.y+34)
						actor.equip = 1
						actor.ammo = actor.ammo + 8
						items[i].c = 0
						items[i].v = 0
					End
				End
			Next
		End
		If scene = 3
			' 死に中
			For Local j = 0 To 35
				If actor.ys[j] < actor.y + 48
					actor.bxs[j] = actor.xs[j]
					actor.bys[j] = actor.ys[j]
					actor.xs[j] = actor.xs[j] + actor.xspeed[j]
					actor.ys[j] = actor.ys[j] + actor.yspeed[j]
					actor.yspeed[j] = actor.yspeed[j] + 2
				End
			Next
			dieCount = dieCount + 1
			If dieCount > 120
				scene = 4
				StopMusic
			End
		End
		
		If scene = 4
			' ゲームオーバー画面
			' スペースキーかZキーでタイトル画面に戻る
			If KeyHit(KEY_Z) Or KeyHit(KEY_SPACE)
				Init()
				PlayMusic("audio/bgm/battle.ogg", 1)
			End
		End
		
		If scene = 5
			' ゲームクリア画面
			' メッセージ表示するだけ
			dieCount = dieCount + 1
			If dieCount > 120
				If KeyHit(KEY_Z) Or KeyHit(KEY_SPACE)
					StopMusic
					Init()
					PlayMusic("audio/bgm/battle.ogg", 1)
				End
			End
		End	
	End
	
	Method OnRender()
		Cls
		If scene = 1
			Local x = 0
			Local y = 0
			Local idx = 0
			For idx = 51 To 57
				DrawImage(chip, x, y, 0, 2, 2, idx)
				x = x + 96
			Next
			x = 0
			y = 96
			For idx = 61 To 67
				DrawImage(chip, x, y, 0, 2, 2, idx)
				x = x + 96
			Next
			x = 0
			y = 192
			For idx = 71 To 77
				DrawImage(chip, x, y, 0, 2, 2, idx)
				x = x + 96
			Next
			x = 0
			y = 288
			For idx = 81 To 87
				DrawImage(chip, x, y, 0, 2, 2, idx)
				x = x + 96
			Next
			x = 0
			y = 384
			For idx = 91 To 97
				DrawImage(chip, x, y, 0, 2, 2, idx)
				x = x + 96
			Next
		End
		
		If scene = 2
			Local mapx = 0
			' マップの描画
			If actor.x < 296
				DrawImage(map, mapx, 0, 0, 1, 1)
			Else
				If actor.x >= 6136
					mapx = -5840
					DrawImage(map, mapx, 0, 0, 1, 1)
				Else
					mapx = 0 - (actor.x - 296)
					DrawImage(map, mapx, 0, 0, 1, 1)
				End
			End

			' ゾンビの死体の描画
			For Local i = 0 To 199
				If zombies[i].s = 1
					For Local j = 0 To 35
						DrawImage(blood, zombies[i].bxs[j] + mapx, zombies[i].bys[j])
						DrawImage(zombieDie1, zombies[i].xs[j] + mapx, zombies[i].ys[j], j)
					Next
				End
			Next			
			
			' アイテムの描画
			For Local i = 0 To 4
				If items[i].v = 1
					DrawImage(chip, items[i].x + mapx, items[i].y, 25)
				End
			Next
			
			' ゾンビの描画			
			For Local i = 0 To 199
				If zombies[i].s = 0
					If zombies[i].d = 0
						If zombies[i].c Mod 20 = 0
							If zombies[i].a = 11
								zombies[i].a = 12
							Else
								zombies[i].a = 11
							End
						End
						DrawImage(chip, zombies[i].x + mapx, zombies[i].y, zombies[i].a)
					Else
						If zombies[i].c Mod 20 = 0
							If zombies[i].a = 14
								zombies[i].a = 15
							Else
								zombies[i].a = 14
							End
						End
						DrawImage(chip, zombies[i].x + mapx, zombies[i].y, zombies[i].a)
					End
				End
			Next
			
			' プレイヤーの描画	
			If actor.x < 296
				DrawImage(chip, actor.x, actor.y, actor.a)
				If actor.d = 1
					If actor.equip = 0
						DrawImage(chip, actor.x + 40, actor.y + 25, 6)
					Elseif actor.equip = 1
						DrawImage(chip, actor.x + 40, actor.y + 24, 8)
					End
					If actor.shot > 0
						If actor.equip = 0
							DrawImage(chip, actor.x + 49, actor.y + 24, 16)
						Elseif actor.equip = 1
							DrawImage(chip, actor.x + 62, actor.y + 13, 18)
						End
					End
				Else
					If actor.equip = 0
						DrawImage(chip, actor.x - 1, actor.y + 25, 7)
					Elseif actor.equip = 1
						DrawImage(chip, actor.x - 16, actor.y + 24, 9)
					End
					If actor.shot > 0
						If actor.equip = 0
							DrawImage(chip, actor.x - 1 - 9, actor.y + 24, 17)
						Elseif actor.equip = 1
							DrawImage(chip, actor.x - 16 - 22, actor.y + 13, 19)
						End
					End
				End
			Else
				If actor.x >= 6136
					DrawImage(chip, actor.x - 5840, actor.y, actor.a)
					If actor.d = 1
						If actor.equip = 0
							DrawImage(chip, actor.x - 5840 + 40, actor.y + 25, 6)
						Elseif actor.equip = 1
							DrawImage(chip, actor.x - 5840 + 40, actor.y + 24, 8)
						End
						If actor.shot > 0
							If actor.equip = 0
								DrawImage(chip, actor.x - 5840 + 49, actor.y + 24, 16)
							Elseif actor.equip = 1
								DrawImage(chip, actor.x - 5840 + 62, actor.y + 13, 18)
							End
						End
					Else
						If actor.equip = 0
							DrawImage(chip, actor.x - 5840 - 1, actor.y + 25, 7)
						Elseif actor.equip = 1
							DrawImage(chip, actor.x - 5840 - 16, actor.y + 24, 9)
						End
						If actor.shot > 0
							If actor.equip = 0
								DrawImage(chip, actor.x - 5840 - 1 - 9, actor.y + 24, 17)
							Elseif actor.equip = 1
								DrawImage(chip, actor.x - 5840 - 16 - 22, actor.y + 13, 19)
							End
						End
					End
				Else
					DrawImage(chip, 296, actor.y, actor.a)
					If actor.d = 1
						If actor.equip = 0
							DrawImage(chip, 296 + 40, actor.y + 25, 6)
						Elseif actor.equip = 1
							DrawImage(chip, 296 + 40, actor.y + 24, 8)
						End
						If actor.shot > 0
							If actor.equip = 0
								DrawImage(chip, 296 + 49, actor.y + 24, 16)
							Elseif actor.equip = 1
								DrawImage(chip, 296 + 62, actor.y + 13, 18)
							End
						End
					Else
						If actor.equip = 0
							DrawImage(chip, 296 - 1, actor.y + 25, 7)
						Elseif actor.equip = 1
							DrawImage(chip, 296 - 16, actor.y + 24, 9)
						End
						If actor.shot > 0
							If actor.equip = 0
								DrawImage(chip, 296 - 1 - 9, actor.y + 24, 17)
							Elseif actor.equip = 1
								DrawImage(chip, 296 - 16 - 22, actor.y + 13, 19)
							End
						End
					End
				End
			End

			' スコアの描画
			DrawImage(chip, 0, 14, 58)
			DrawImage(chip, 48, 14, 59)
			' 6桁
			Local nx = 192
			Local ny = 6
			Local nidx = 0
			' 1桁目表示
			nx = 216
			nidx = Floor(score Mod 10)
			DrawImage(numbers, nx, ny, nidx)
			' 2桁目表示
			nx = 192
			nidx = Floor(score / 10)
			nidx = nidx Mod 10
			DrawImage(numbers, nx, ny, nidx)
			' 3桁目表示
			nx = 168
			nidx = Floor(score / 100)
			nidx = nidx Mod 10
			DrawImage(numbers, nx, ny, nidx)
			' 4桁目表示
			nx = 144
			nidx = Floor(score / 1000)
			nidx = nidx Mod 10
			DrawImage(numbers, nx, ny, nidx)
			' 5桁目
			nx = 120
			nidx = Floor(score / 10000)
			nidx = nidx Mod 10
			DrawImage(numbers, nx, ny, nidx)
			' 6桁目
			nx = 96
			nidx = Floor(score / 100000)
			nidx = nidx Mod 10
			DrawImage(numbers, nx, ny, nidx)
			
			' 弾薬の描画
			If actor.equip = 1
				' 弾丸アイコンの描画
				DrawImage(chip, 0, 48, 68)
				' 2桁
				Local nax = 192
				Local nay = 64
				Local naidx = 0
				' 1桁目表示
				nax = 64
				naidx = Floor(actor.ammo Mod 10)
				DrawImage(numbers, nax, nay, naidx)
				' 2桁目表示
				nax = 38
				naidx = Floor(actor.ammo / 10)
				naidx = naidx Mod 10
				DrawImage(numbers, nax, nay, naidx)
			End
		End
		
		If scene = 3
			Local mapx = 0
			' マップの描画
			If actor.x < 296
				DrawImage(map, mapx, 0, 0, 1, 1)
			Else
				If actor.x >= 6136
					mapx = -5840
					DrawImage(map, mapx, 0, 0, 1, 1)
				Else
					mapx = 0 - (actor.x - 296)
					DrawImage(map, mapx, 0, 0, 1, 1)
				End
			End
			
			' ゾンビの描画
			For Local i = 0 To 199
				If zombies[i].s = 1
					For Local j = 0 To 35
						DrawImage(blood, zombies[i].bxs[j] + mapx, zombies[i].bys[j])
						DrawImage(zombieDie1, zombies[i].xs[j] + mapx, zombies[i].ys[j], j)
					Next
				End
			Next
			
			For Local i = 0 To 199
				If zombies[i].s = 0
					If zombies[i].d = 0
						If zombies[i].c Mod 20 = 0
							If zombies[i].a = 11
								zombies[i].a = 12
							Else
								zombies[i].a = 11
							End
						End
						DrawImage(chip, zombies[i].x + mapx, zombies[i].y, zombies[i].a)
					Else
						If zombies[i].c Mod 20 = 0
							If zombies[i].a = 14
								zombies[i].a = 15
							Else
								zombies[i].a = 14
							End
						End
						DrawImage(chip, zombies[i].x + mapx, zombies[i].y, zombies[i].a)
					End
				End
			Next
			
			For Local j = 0 To 35
				DrawImage(blood, actor.bxs[j] + mapx, actor.bys[j])
				DrawImage(actorDie1, actor.xs[j] + mapx, actor.ys[j], j)
			Next
		End
		
		If scene = 4
			DrawText("GAME OVER", 288, 234)
		End
		
		If scene = 5
			DrawText("CONGRATULATIONS!", 264, 234)
		End
	End
	
	' 矩形と線分の当たり判定
	' 線分1が bx, by  cx, cy
	' 線分2を px, py  qx, qy で表す
	Method LineAndLine(bx, by, cx, cy, px, py, qx, qy)
		Local nRet1 = ((px - bx) * (cy - by) - (py - by) * (cx - bx)) * ((qx - bx) * (cy - by) - (qy - by) * (cx - bx))
		Local nRet2 = ((bx - px) * (qy - py) - (by - py) * (qx - px)) * ((cx - px) * (qy - py) - (cy - py) * (qx - px))
		If nRet1 <= 0 And nRet2 <= 0
			Return True
		End
		Return False
	End
	
	Method ZombieHit(z:Zombie, px, py, qx, qy)
		If LineAndLine(z.x, z.y, z.x, z.y+48, px, py, qx, qy)
			Return True
		End
		If LineAndLine(z.x+48, z.y, z.x+48, z.y+48, px, py, qx, qy)
			Return True
		End
		Return False
	End
	
	' 二点間の距離を求める
	Method Distance(ax, ay, bx, by)
		Local d1 = Abs(bx - ax)
		d1 = d1 * d1
		Local d2 = Abs(by - ay)
		d2 = d2 * d2
		Local a = d1 + d2
		a = Sqrt(a)
		Return a
	End
	
	' 矩形の当たり判定
	Method HitBox(mx1, my1, mx2, my2, ex1, ey1, ex2, ey2)
		If (mx1 <= ex2 And ex1 <= mx2 And my1 <= ey2 And ey1 <= my2)
			Return True
		End
		Return False
	End
End

Function Main()
	New Game()
End