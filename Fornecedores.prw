#include "Rwmake.ch"
#include "Protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"

/*
//------------------------
Autor: João Henrique Dib
Projeto: Tarefa de criação de tela
09/04/2024
//------------------------
*/

User Function tarefaF()

	Local oButton1
	Local oButton2
	Local oMsDialog
	Local oLinha
	Local oFont := TFont():New('Arial',,24,.T.)
	Local _aSize := MsAdvSize()
	Private num := 0
	Private oFont2 := TFont():New('Arial',,13,.T.)
	Private aCord := {0,0,0,0}
	Private oBrowse

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT"

	aCord[1] := 5
	aCord[2] := 5
	aCord[3] := 320
	aCord[4] := 575

	_aSize[5] := 1522
	_aSize[6] := 684
	oFont:Bold := .T.

	oMsDialog := TDialog():New(0, 0, _aSize [6]-30, _aSize [5]-200,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)



/////////////////////// CRIANDO VISÃO DO BANCO ///////////////////////
	dbSelectArea("SA2")

	oBrowse := MsSelBr():New( 5,5,570,315,,,,oMsDialog,,,,,,,,,,,,.F.,'SA2',.T.,,.F.,,, )
	oBrowse:AddColumn(TCColumn():New('Codigo',{||SA2->A2_COD },,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Loja'  ,{||SA2->A2_LOJA},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Nome'  ,{||SA2->A2_NOME},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('CPF/CNPJ'  ,{||SA2->A2_CGC},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:lHasMark := .T.
	oBrowse:bAllMark := {|| alert('Click no header da browse') }

/////////////////////// BOTÕES ///////////////////////
	oButton1 := TButton():Create(oMsDialog,65,585,"Inserir",{||insert()},75,20,,,,.T.,,,,,,)
	oButton2 := TButton():Create(oMsDialog,95,585,"Editar",{||update(SA2->A2_COD)},75,20,,,,.T.,,,,,,)
	oButton3 := TButton():Create(oMsDialog,125,585,"Deletar",{||delete()},75,20,,,,.T.,,,,,,)
	oButton1 := TButton():Create(oMsDialog,35,585,"Visualizar",{||view()},75,20,,,,.T.,,,,,,)
/////////////////////// ATIVANDO JANELA ///////////////////////
	oMsDialog:Activate(,,,.T.,,,)




	RESET ENVIRONMENT
RETURN


Static Function insert()
	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aEstados2 := {}
	Local cTGet1
	Local cTGet2
	Local cTGet3
	Local cTGet4
	Local cTGet5
	Local cTGet6
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial
	Local nNumero
	Local cCombo   := ""
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)



	/////////////////////// ABAS ///////////////////////
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,300 )


	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next


	/////////////////////// ABA 'Cadastrais' ///////////////////////

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,cTGet1,cTGet1:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet1,,,,,,,'Código:',1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,cTGet2,cTGet2:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet2,,,,,,,'Loja:',1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,cTGet3,cTGet3:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet3,,,,,,,'Nome Fantasia:',1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,cCombo:=u,cCombo)}, aEstados2, 100, , oTFolder:aDialogs[1], , , , , , .T., ,, , , , , , , cCombo, 'Estado', 1, , )

	oMunicipio    := TGet():New( 85, 1, {|u|if(PCount()==0,cTGet4,cTGet4:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet4,,,,,,,'Município:',1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,cTGet5,cTGet5:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet5,,,,,,,'Endereço:',1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,cTGet6,cTGet6:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, cTGet6,,,,,,,'Razão Social:',1,,,,.T.,)

	oButton3      := TButton():Create(oJanela,150,1,"Teste código",{||insertDb(cTGet1,cTGet2,cTGet3,cCombo,cTGet4,cTGet5,cTGet6,oJanela)},75,20,,,,.T.,,,,,,)

	oJanela:Activate(,,,.T.,,,)


RETURN
Static Function insertDb(codigo, loja,fantasia,estado,municipio,endereco,razao, oJanela)

	dbSelectArea("SA2")
	DBGOTOP()

	RecLock("SA2", .T.)
	A2_COD := codigo
	A2_NOME := fantasia
	A2_LOJA := loja
	A2_TIPO := 'F'
	A2_END := endereco
	A2_EST := estado
	A2_MUN := municipio
	A2_NREDUZ := razao
	MsUnlock()

	SA2->(dbCloseArea())

	msgInfo("Inserido com sucesso")
	oJanela:end()


RETURN


Static Function update(cIdLinha)
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local nNumero := 0
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local cTGet1 := SA2->A2_COD
	Local cTGet2 := SA2->A2_LOJA
	Local cTGet3 := SA2->A2_NOME
	Local cTGet4 := SA2->A2_MUN
	Local cTGet5 := SA2->A2_END
	Local cTGet6 := SA2->A2_NREDUZ
	Local aEstados2 := {}
	Local cCombo := SA2->A2_EST
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next


	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,cTGet1,cTGet1:=u)}, oJanela, 096, 009, "@N 9999999999",,0,,,,, .T.,,,,,,,,,, cTGet1,,,,,,,'Código:',1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,cTGet2,cTGet2:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,,,, cTGet2,,,,,,,'Loja:',1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,cTGet3,cTGet3:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,,,, cTGet3,,,,,,,'Nome Fantasia:',1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,cCombo:=u,cCombo)}, aEstados2, 100, , oJanela, , , , , , .T., ,, , , , , , , cCombo, 'Estado', 1, , )
	oEstado:Select(aScan(aEstadosSiglas, SA2->A2_EST))

	oMunicipio    := TGet():New( 85, 1, {|u|if(PCount()==0,cTGet4,cTGet4:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,,,, cTGet4,,,,,,,'Município:',1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,cTGet5,cTGet5:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T.,,,,,,,,,, cTGet5,,,,,,,'Endereço:',1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,cTGet6,cTGet6:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T.,,,,,,,,,, cTGet6,,,,,,,'Razão Social:',1,,,,.T.,)

	oButton3      := TButton():Create(oJanela,150,1,"Teste código",{||updateDb(SA2->(RecNo()),cTGet1,cTGet2,cTGet3,aEstadosSiglas[aScan(aEstados2, cCombo)],cTGet4,cTGet5,cTGet6,oJanela)},75,20,,,,.T.,,,,,,)




	oJanela:Activate(,,,.T.,,,)

	msgInfo(cIdLinha)


RETURN



Static Function updateDb(recno, codigo, loja, fantasia, estado, municipio, endereco, razao, oJanela)
	Local cQryUpd
	cQryUpd := "UPDATE " + RetSqlName("SA2") + " "
	cQryUpd += "SET a2_cod = '" + codigo + "', "
	cQryUpd += "a2_loja = '" + loja + "', "
	cQryUpd += "a2_nome = '" + fantasia + "', "
	cQryUpd += "a2_nreduz = '" + razao + "', "
	cQryUpd += "a2_end = '" + endereco + "', "
	cQryUpd += "a2_est = '" + estado + "', "
	cQryUpd += "a2_mun = '" + municipio + "' "
	cQryUpd += "WHERE R_E_C_N_O_ = '" + cValToChar(recno) + "' "
	cQryUpd += "AND D_E_L_E_T_ = ' '"

	nErro := TcSqlExec(cQryUpd)

	If nErro != 0

		msgStop("Erro.")

	Endif

	oJanela:end()




RETURN



Static Function delete()
	Local oJanela  := TDialog():New(0, 0, 100, 300,'Delete de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local oButton1
	Local oButton2

	oButton2 	  :=TButton():Create(oJanela,30,10,"Apagar",{||deleteDb(SA2->(RecNo()), oJanela)},55,20,,,,.T.,,,,,,)
	oButton1      := TButton():Create(oJanela,30,90,"Cancelar",{||oJanela:end()},55,20,,,,.T.,,,,,,)



	oJanela:Activate(,,,.T.,,,)


RETURN


Static Function deleteDb(recno, oJanela)

	Local cQryUpd
	cQryUpd := "UPDATE " + RetSqlName("SA2") + " "
	cQryUpd += "SET D_E_L_E_T_ = '" + "*" + "', "
	cQryUpd += "R_E_C_D_E_L_ = '" + cValToChar(recno) + "'"
	cQryUpd += "WHERE R_E_C_N_O_ = '" + cValToChar(recno) + "' "
	cQryUpd += "AND D_E_L_E_T_ = ' '"

	nErro := TcSqlExec(cQryUpd)

	If nErro != 0

		msgStop("Erro.")

	Endif

	oJanela:end()
	oBrowse:refresh()

RETURN


Static Function view()
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local nNumero := 0
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local cTGet1 := SA2->A2_COD
	Local cTGet2 := SA2->A2_LOJA
	Local cTGet3 := SA2->A2_NOME
	Local cTGet4 := SA2->A2_MUN
	Local cTGet5 := SA2->A2_END
	Local cTGet6 := SA2->A2_NREDUZ
	Local aEstados2 := {}
	Local cCombo 
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next


	cCombo := aEstados2[aScan(aEstadosSiglas, SA2->A2_EST)]

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,cTGet1,cTGet1:=u)}, oJanela, 096, 009, "@N 9999999999",,0,,,,, .T.,,,,,,,.T.,,, cTGet1,,,,,,,'Código:',1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,cTGet2,cTGet2:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,.T.,,, cTGet2,,,,,,,'Loja:',1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,cTGet3,cTGet3:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,.T.,,, cTGet3,,,,,,,'Nome Fantasia:',1,,,,.T.,)

	oEstado       :=  TGet():New( 60, 1, {|u|if(PCount()==0,cCombo,cCombo:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,.T.,,, cCombo,,,,,,,'Estado',1,,,,.T.,)

	oMunicipio    := TGet():New( 80, 1, {|u|if(PCount()==0,cTGet4,cTGet4:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. ,,,,,,,.T.,,, cTGet4,,,,,,,'Município:',1,,,,.T.,)

	oEndereco     := TGet():New( 100, 1, {|u|if(PCount()==0,cTGet5,cTGet5:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T.,,,,,,,.T.,,, cTGet5,,,,,,,'Endereço:',1,,,,.T.,)

	oRazaoSocial  := TGet():New( 120, 1, {|u|if(PCount()==0,cTGet6,cTGet6:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T.,,,,,,,.T.,,, cTGet6,,,,,,,'Razão Social:',1,,,,.T.,)






	oJanela:Activate(,,,.T.,,,)




RETURN
