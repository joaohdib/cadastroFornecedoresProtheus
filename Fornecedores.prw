#include "Rwmake.ch"
#include "Protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"

/*
//------------------------
Autor: João Henrique Dib
Projeto: Tarefa de criação de rotina para trabalhar com a tabela SA2
16/04/2024
//------------------------
*/

User Function tarefaF()

	Local oButton1
	Local oButton2
	Local oButton3
	Local oButton4
	Local oButton5
	Local oMsDialog
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

	oButton4 := TButton():Create(oMsDialog,35,585,"Visualizar",{||view()},75,20,,,,.T.,,,,,,)

	oButton5 := TButton():Create(oMsDialog,155,585,"Gerar relatório completo",{||view()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,185,585,"Gerar relatório resumido",{||PRINTGRAPH()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,215,585,"Fechar",{||oMsDialog:end()},75,20,,,,.T.,,,,,,)

	/////////////////////// ATIVANDO JANELA ///////////////////////
	oMsDialog:Activate(,,,.T.,,,)




	RESET ENVIRONMENT
RETURN


Static Function insert()
	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aEstados2 := {}
	Local aTipos := {"F - Físico", "J - Jurídico"}
	Local aValores := {{'','Código'},{'','Loja'},{'','Nome Fantasia'},{'','Estado'},{'','Municipio'},{'','Endereço'},{'','Razão Social'}, {'','Tipo'}}
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial
	Local oTipo
	Local nNumero
	Local cTipo
	Local cCombo   := ""
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)



	/////////////////////// ABAS ///////////////////////
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,300 )


	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next


	/////////////////////// ABA 'Cadastrais' ///////////////////////

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oTFolder:aDialogs[1], , , , , , .T., ,, , , , , , , aValores[4][1], aValores[4][2], 1, , )

	oMunicipio    := TGet():New( 85, 1, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	//cTipo		  := TSay():New( 145, 1, {||'Tipo'}, oTFolder:aDialogs[1] , , , , , , .T., ,,,, ,, ,,, ,,  )
	oTipo 		  := TComboBox():New( 150, 1, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oTFolder:aDialogs[1], , , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )


	oButton3      := TButton():Create(oJanela, 185,1,"Teste código",{||insertDb(aValores,oJanela)},75,20,,,,.T.,,,,,,)



	oJanela:Activate(,,,.T.,,,)


RETURN

Static Function insertDb(aValores, oJanela)
	Local aValoresFaltantes := verificaValores(aValores)
	Local cValoresTexto := ''
	Local nI 
	If Len(aValoresFaltantes) > 0 
		For nI := 1 To Len(aValoresFaltantes)
			cValoresTexto += aValoresFaltantes[nI]
			cValoresTexto += ' '
			cValoresTexto += Chr(13)+Chr(10)
		Next
		FWAlertError("Os seguintes valores não podem estar vazios:" + Chr(13)+Chr(10) + cValoresTexto ,"Erro na inserção")
		RETURN
	Endif


	dbSelectArea("SA2")
	DBGOTOP()

	RecLock("SA2", .T.)
    A2_COD := aValores[1][1]     // Código
    A2_NOME := aValores[2][1]      // Fantasia
    A2_LOJA := aValores[3][1]      // Loja
    A2_TIPO := Left(aValores[8][1], 1)             // Tipo 
    A2_END := aValores[6][1]       // Endereço
    A2_EST := aValores[4][1]       // Estado
    A2_MUN := aValores[5][1]       // Município
    A2_NREDUZ := aValores[7][1]   
	MsUnlock()

	SA2->(dbCloseArea())

	FWAlertSuccess("Inserido com sucesso", "Inserido")
	oJanela:end()


RETURN


Static Function update(cIdLinha)
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local nNumero := 0
	Local aValores := {{SA2->A2_COD,'Código'},{SA2->A2_LOJA,'Loja'},{SA2->A2_NOME,'Nome Fantasia'},{SA2->A2_EST,'Estado'},{SA2->A2_MUN,'Municipio'},{SA2->A2_END,'Endereço'},{SA2->A2_NREDUZ,'Razão Social'}, {A2_TIPO,'Tipo'}}
	Local aTipos := {"F - Físico", "J - Jurídico"}
	LOcal aTiposVerificacao := {"F","J"}
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local aEstados2 := {}
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



	

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)},oJanela, 096, 009, "@N 9999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oJanela, 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oJanela, , , , , , .T., ,, , , , , , , aValores[4][1], 'Estado', 1, , )
	oEstado:Select(aScan(aEstadosSiglas, SA2->A2_EST))

	oMunicipio    := TGet():New( 85, 1, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oJanela, 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)
	
	//cTipo		  := TSay():New( 145, 1, {||'Tipo'}, oTFolder:aDialogs[1] , , , , , , .T., ,,,, ,, ,,, ,,  )
	oTipo 		  := TComboBox():New( 150, 1, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oJanela, , , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )
	oTipo:Select(AScan(aTiposVerificacao, SA2->A2_TIPO))


	oButton3      := TButton():Create(oJanela,185,1,"Atualizar",{||updateDb(SA2->(RecNo()),aValores,oJanela)},75,20,,,,.T.,,,,,,)


	oJanela:Activate(,,,.T.,,,)



RETURN



Static Function updateDb(recno, aValores, oJanela)
	Local aValoresFaltantes := verificaValores(aValores)
	Local cValoresTexto := ''
	Local cQryUpd
	Local nI 
	If Len(aValoresFaltantes) > 0 
		For nI := 1 To Len(aValoresFaltantes)
			cValoresTexto += aValoresFaltantes[nI]
			cValoresTexto += ' '
			cValoresTexto += Chr(13)+Chr(10)
		Next
		FWAlertError("Os seguintes valores não podem estar vazios:" + Chr(13)+Chr(10) + cValoresTexto ,"Erro na atualização")
		RETURN
	Endif


	cQryUpd := "UPDATE " + RetSqlName("SA2") + " "
	cQryUpd += "SET a2_cod = '" + aValores[1][1] + "', "
	cQryUpd += "a2_loja = '" + aValores[2][1] + "', "
	cQryUpd += "a2_nome = '" + aValores[3][1] + "', "
	cQryUpd += "a2_nreduz = '" + aValores[4][1] + "', "
	cQryUpd += "a2_end = '" + aValores[5][1] + "', "
	cQryUpd += "a2_est = '" + aValores[6][1] + "', "
	cQryUpd += "a2_mun = '" + aValores[7][1] + "' "
	cQryUpd += "a2_tipo = '" + Left(aValores[8][1], 1) + "' "
	cQryUpd += "WHERE R_E_C_N_O_ = '" + cValToChar(recno) + "' "
	cQryUpd += "AND D_E_L_E_T_ = ' '"

	nErro := TcSqlExec(cQryUpd)

	If nErro != 0

		msgStop("Erro.")

	Endif


	FWAlertSuccess("Atualizado com sucesso", "Atualizado")
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


//nome tipo cpf/cgc

Static Function verificaValores(aValores)
	Local aNomeValores := {}
	Local nI

	For nI := 1 to Len(aValores)
		valor := aValores[nI][1]
		nome := aValores[nI][2]

		If valor == ''
			AADD(aNomeValores,nome)
		Endif
	Next


RETURN aNomeValores


Static Function PRINTGRAPH()

Local oReport as Object
Local oSection as Object

//Classe TREPORT
oReport := TReport():New('Relatório',"Fornecedores",/*cPerg*/,{|oReport|ReportPrint(oReport,oSection)})

//Seção 1 
oSection := TRSection():New(oReport,'Fornecedores')

//Definição das colunas de impressão da seção 1
TRCell():New(oSection, "A2_NOME" , "TRB", "Nome", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "A2_TIPO", "TRB", "Tipo" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "A2_CGC" , "TRB", "CGC/CPF"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

//Definição da collection
//oColl:=TRCollection():New("TOTAL UF", "COUNT", /*oBreak*/,"Total POR UF",;
///*cPicture*/, /*uFormula*/ oSection:Cell("A1_COD"), /*.lEndSection.*/ .F.,;
///*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,;
///*uContent*/ oSection:Cell("A1_EST") ) 

oReport:PrintGraphic()
oReport:PrintDialog()

Return

Static Function ReportPrint(oReport,oSection)

#IFDEF TOP

    Local cAlias := "TRB"

    BEGIN REPORT QUERY oSection

        BeginSql alias cAlias
            SELECT A2_NOME,A2_TIPO,A2_CGC
            FROM %table:SA2% 
        EndSql

    END REPORT QUERY oSection 

    //oSection:aCollection[1]:SetGraphic(4,"UF")
    oSection:PrintGraphic()
    oSection:Print()

#ENDIF

return
