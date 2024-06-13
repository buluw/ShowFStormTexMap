/*-------------------------------------------------------------------------------------------
本脚本由 Yanjicg 开发，按照 GPL 3.0 协议开源，
你可以自由使用、修改和分发本脚本，但必须保留本声明信息。
任何人、机构、企业不得更改署名信息。
本脚本基于 GPL V3.0 协议开源，更多信息请参考：https://www.gnu.org/licenses/

@FileName: ShowFStormTexMap.ms
@Creat Date: 2024-06-14
@Modify Date : 2024-06-14
@Version: 1.0.0
@Author: Yanjicg/buluw
@License: GNU General Public License, version 3 (GPL-3.0)


Copyright (C)2024 yanjicg.com

This maxscript is open source: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This maxscript is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.If not, see < https://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------------------*/
(  
	global FStormBitmapArr = #()
	global FSmixMatsubnodetex
	global mats = #()
	QuickShowFStormbitmap = struct showFStormbitmap  
	(  
		fn findSubTex matOrTexnode nodeCount=  
		(  
			for nodeIndex=1 to nodeCount do  
			(  
				local SubTexMapNode = getSubTexmap matOrTexnode nodeIndex  
				if SubTexMapNode != undefined do  
				(  
					if classof SubTexMapNode == FStormBitmap then  
					(  
						append FStormBitmapArr SubTexMapNode  
						return FStormBitmapArr  
					)  
					else  
					(  
						local aNodeNum = getNumSubTexmaps SubTexMapNode  
						if aNodeNum != 0 do  
						(  
							QuickShowFStormbitmap.findSubTex SubTexMapNode aNodeNum  
						)  
					)  
				)  
			)  
		),  
		fn showTexMap item =  
		(  
			if item != undefined do  
			(  
				local nodeCount = getNumSubTexmaps item  
				if nodeCount != 0 do  
				(  
					QuickShowFStormbitmap.findSubTex item nodeCount  
					if FStormBitmapArr[1] != undefined do showTexturemap item FStormBitmapArr[1] true;windows.processPostedMessages()
					FStormBitmapArr = #()  
				)  
			)  
		),  
		fn showMixMatMap item mat =  
		(  
			local cMat = mat  
			local nodeCount = getNumSubTexmaps item  
			if nodeCount != 0 do  
			(  
				QuickShowFStormbitmap.findSubTex item nodeCount  
				if FStormBitmapArr[1] != undefined do showTexturemap cMat FStormBitmapArr[1] true;windows.processPostedMessages()
				FStormBitmapArr = #()  
				FSmixMatsubnodetex = undefined  
			)  
		),  
		fn handleFSmixMat item count =  
		(  
			if count == 1 then FSmixMatsubnodetex = item  
			if item.material1 != undefined then  
			(  
				local matname = "混合材质"  
				case classof item.material1 of  
				(  
					FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item.material1 2  
					Multimaterial:  QuickShowFStormbitmap.nowordtobb "多维子材质" matname  
					FStormOverrideMat:  QuickShowFStormbitmap.nowordtobb "覆盖材质" matname  
					FStormSwitchMat:  QuickShowFStormbitmap.nowordtobb "切换材质" matname  
					FStormProjectMat:  QuickShowFStormbitmap.nowordtobb "投影材质" matname  
					default:  QuickShowFStormbitmap.showMixMatMap item.material1 FSmixMatsubnodetex  
				)  
			)  
			else  
			(  
				case classof item.material2 of  
				(  
					FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item.material2 2  
					Multimaterial:  QuickShowFStormbitmap.nowordtobb "多维子材质" matname  
					FStormOverrideMat:  QuickShowFStormbitmap.nowordtobb "覆盖材质" matname  
					FStormSwitchMat:  QuickShowFStormbitmap.nowordtobb "切换材质" matname  
					FStormProjectMat:  QuickShowFStormbitmap.nowordtobb "投影材质" matname  
					default:  QuickShowFStormbitmap.showMixMatMap item.material2 FSmixMatsubnodetex  
				)  
			)  
		),  
		fn nowordtobb word mat =  
		(  
			print "在" + mat + "里嵌套" + word + "...我也无fuck说，别显示贴图了赶紧改材质吧"  
		),  
		fn handleOverrideMat item =  
		(  
			if item.base != undefined do  
			(  
				local oMat = item  
				local matname = "覆盖材质"  
				case classof item.base of  
				(  
					Multimaterial:  QuickShowFStormbitmap.nowordtobb "多维子材质" matname  
					FStormOverrideMat:  QuickShowFStormbitmap.nowordtobb "覆盖材质" matname  
					FStormSwitchMat:  QuickShowFStormbitmap.nowordtobb "切换材质" matname  
					FStormProjectMat:  QuickShowFStormbitmap.nowordtobb "投影材质" matname  
					FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item.base 1  
					default:  QuickShowFStormbitmap.showMixMatMap item.base oMat  
				)  
			)  
		),  
		fn handleMultiMat item =  
		(  
			for n=1 to item.numsubs do QuickShowFStormbitmap.hanldleMatclass item[n]
		),  
		fn handleSwitchMat item =  
		(  
			sMat = item  
			matname = "切换材质"  
			if item.materials[item.mat_use] != undefined do  
			(  
				case classof item.materials[item.mat_use] of  
				(  
					Multimaterial:  QuickShowFStormbitmap.handleMultiMat item.materials[item.mat_use]  
					FStormOverrideMat:  QuickShowFStormbitmap.handleOverrideMat item.materials[item.mat_use]  
					FStormSwitchMat:  QuickShowFStormbitmap.nowordtobb "切换材质" matname  
					FStormProjectMat:  QuickShowFStormbitmap.nowordtobb "投影材质" matname  
					FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item.materials[item.mat_use] 1  
					default:  QuickShowFStormbitmap.showMixMatMap item.materials[item.mat_use] sMat
				)
			)
		),  
		fn handleProjectMat item =  
		(
			local pMat = item  
			local matname = "投影材质"  
			if item.base_material != undefined do  
			(  
				case classof item.base_material of  
				(  
					Multimaterial:  QuickShowFStormbitmap.nowordtobb "多维子材质" matname
					FStormOverrideMat:  QuickShowFStormbitmap.nowordtobb "覆盖材质" matname
					FStormSwitchMat:  QuickShowFStormbitmap.nowordtobb "切换材质" matname
					FStormProjectMat:  QuickShowFStormbitmap.nowordtobb "投影材质" matname
					FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item.base_material 1  
					default:  QuickShowFStormbitmap.showMixMatMap item.base_material pMat  
				)  
			)  
		),  
		fn hanldleMatclass item =  
		(  
			case classof item of  
			(  
				Multimaterial:  QuickShowFStormbitmap.handleMultiMat item  
				FStormMixMat:  QuickShowFStormbitmap.handleFSmixMat item 1  
				FStormOverrideMat:  QuickShowFStormbitmap.handleOverrideMat item  
				FStormSwitchMat:  QuickShowFStormbitmap.handleSwitchMat item  
				FStormProjectMat:  QuickShowFStormbitmap.handleProjectMat item  
				default:  QuickShowFStormbitmap.showTexMap item
			)  
		), 
		fn findInMat mat =  
		(  
			for item in mat do QuickShowFStormbitmap.hanldleMatclass item
		)
	)  

	for obj in objects where iskindof obj.mat Material do appendifunique mats obj.mat
	QuickShowFStormbitmap.findInMat mats
    mats = #()
)
