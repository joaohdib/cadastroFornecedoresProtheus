#include "Rwmake.ch"
#include "Protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "totvs.ch"

/*
//------------------------
Autor: João Henrique Dib
Projeto: Tarefa de criação de rotina para trabalhar com a tabela SA2
24/04/2024
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
	//oBrowse:bAllMark := {|| alert('Click no header da browse') }

	/////////////////////// BOTÕES ///////////////////////
	oButton1 := TButton():Create(oMsDialog,15,581,"Inserir",{||insert()},75,20,,,,.T.,,,,,,)

	oButton2 := TButton():Create(oMsDialog,45,581,"Editar",{||update(SA2->A2_COD)},75,20,,,,.T.,,,,,,)

	oButton3 := TButton():Create(oMsDialog,75,581,"Deletar",{||delete()},75,20,,,,.T.,,,,,,)

	oButton4 := TButton():Create(oMsDialog,105,581,"Visualizar",{||view()},75,20,,,,.T.,,,,,,)

	oButton5 := TButton():Create(oMsDialog,135,581,"Gerar relatório completo",{||view()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,165,581,"Gerar relatório resumido",{||PRINTGRAPH()},75,20,,,,.T.,,,,,,)

	oButton6 := TButton():Create(oMsDialog,195,581,"Fechar",{||oMsDialog:end()},75,20,,,,.T.,,,,,,)

	/////////////////////// ATIVANDO JANELA ///////////////////////
	oMsDialog:Activate(,,,.T.,,,)




	RESET ENVIRONMENT
RETURN


Static Function insert()
	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aPaises 	:= trataPaises()
	Local aEstados2 := {}
	Local aSimNao	:= {"2 - Não", "1 - Sim"}
	Local aTipos := {"F - Físico", "J - Jurídico"}
	Local aValores := {{'','Código'},{'','Loja'},{'','Nome Fantasia'},{'','Estado'},{'','Municipio'},{'','Endereço'},{'','Razão Social'}, {'','Tipo'}}
	Local aValoresN := ;
		{{'','CPF/CNPJ'}, {'','Código Município'}, {'', 'Telefone'}, {'', 'RG/Ced.Estr.'}, {'', 'Ins. Estad.'}, {'', 'Ins. Municip.'}, {'', 'DDI'}, {'','País'}, {'','DDD'},;
		{'','Descr. País'},{'','Departamento'},{'','Email'},{'','Homepage'},{'','TELEX'},{'','END. COMPLEMENTAR'},{'','Bloqueado'},{'','Complemento'},{'','Forn.Mailing'}, {'','Cod CBO'},{'','Cod CNAE'}}
		//{'','Banco'}, {'','Cod. Agência'}, {'','Cta Corrente'}, {'',''}}
	Local aMunicipios := {}
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial
	Local oTipo
	Local oCGC
	Local oTelefone
	Local oCodMun
	Local oDdd
	Local oDdi
	Local oBanco
	Local oCodAgencia
	Local oCtCorrente
	Local OPFisica
	Local nNumero
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)



	/////////////////////// ABAS ///////////////////////
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,300 )


	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next


	/////////////////////// ABA 'Cadastrais' ///////////////////////

	oCodigo       := TGet():New( 000, 001, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 000, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 020, 001, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oCodMun		  := TComboBox():New( 020, 100, {|u|if(PCount()>0,aValoresN[2][1]:=u,aValoresN[2][1])}, aMunicipios, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[2][1], aValoresN[2][2], 1, , )

	oNFantasia    := TGet():New( 040, 001, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 040, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 060, 001, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oTFolder:aDialogs[1], , {||getComboMunicipios(oEstado, @oCodMun)}, , , , .T., ,, , , , , , , aValores[4][1], aValores[4][2], 1, , )
	getComboMunicipios(oEstado, @oCodMun)

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 085, 001, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 001, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 001, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[7][1],aValoresN[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[7][1],,,,,,,aValoresN[7][2],1,,,,.T.,)

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oPais 		  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[8][1]:=u,aValoresN[8][1])}, aPaises, 200, , oTFolder:aDialogs[1], ,{|| trocaDescPais(aValoresN[8][1], @oDescPais)}, , , , .T., ,, , , , , , , aValoresN[8][1], aValoresN[8][2], 1, , )

	oDescPais	  := TGet():New( 200, 100, {|u|if(PCount()==0,aValoresN[10][1],aValoresN[10][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[10][1],,,,,,,aValoresN[10][2],1,,,,.T.,)

	oDept 		  := TGet():New( 0, 200, {|u| if(PCount()==0, aValoresN[11][1], aValoresN[11][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[11][1],,,,,,, aValoresN[11][2],1,,,,.T.,)

	oEmail 		  := TGet():New( 20, 200, {|u| if(PCount()==0, aValoresN[12][1], aValoresN[12][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[12][1],,,,,,, aValoresN[12][2],1,,,,.T.,)

	oHpage 		  := TGet():New( 40, 200, {|u| if(PCount()==0, aValoresN[13][1], aValoresN[13][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[13][1],,,,,,, aValoresN[13][2],1,,,,.T.,)

	oTelex 		  := TGet():New( 60, 200, {|u| if(PCount()==0, aValoresN[14][1], aValoresN[14][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[14][1],,,,,,, aValoresN[14][2],1,,,,.T.,)

	oEndcomp 	  := TGet():New( 80, 200, {|u| if(PCount()==0, aValoresN[15][1], aValoresN[15][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[15][1],,,,,,, aValoresN[15][2],1,,,,.T.,)

	oBloq         := TComboBox():New( 100, 200, {|u|if(PCount()>0,aValoresN[16][1]:=u,aValoresN[16][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[16][1], aValoresN[16][2], 1, , )

	oComplem      := TGet():New( 120, 200, {|u| if(PCount()==0, aValoresN[17][1], aValoresN[17][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXXXXXXXX", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[17][1],,,,,,, aValoresN[17][2],1,,,,.T.,)

	oForm         := TComboBox():New( 140, 200, {|u|if(PCount()>0,aValoresN[18][1]:=u,aValoresN[18][1])}, aSimNao, 100, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[18][1], aValoresN[18][2], 1, , )

	oCbo		  := TGet():New( 160, 200, {|u| if(PCount()==0, aValoresN[19][1], aValoresN[19][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[19][1],,,,,,, aValoresN[19][2],1,,,,.T.,)

	oCnae 		  := TGet():New( 180, 200, {|u| if(PCount()==0, aValoresN[20][1], aValoresN[20][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 9999-9/9999", ,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[20][1],,,,,,, aValoresN[20][2],1,,,,.T.,)
	oCnae:lReadOnly := .T.

	oTipo 		  := TComboBox():New( 150, 001, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oTFolder:aDialogs[1], ,{||verificaCgc(oTipo, @oCGC, @oCbo, @oCnae)} , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )



	/////////////////////// ABA 'Adm/Fin.' ///////////////////////

	oBanco		  := TGet():New( 000, 001, {|u|if(PCount()==0,aValoresN[10][1],aValoresN[10][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[10][1],,,,,,,aValoresN[10][2],1,,,,.T.,)

	oCodAgencia	  := TGet():New( 020, 001, {|u|if(PCount()==0,aValoresN[11][1],aValoresN[11][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 99999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[11][1],,,,,,,aValoresN[11][2],1,,,,.T.,)

	oCtCorrente   := TGet():New( 040, 001, {|u|if(PCount()==0,aValoresN[12][1],aValoresN[12][1]:=u)}, oTFolder:aDialogs[2], 096, 009, "@N 99999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[12][1],,,,,,,aValoresN[12][2],1,,,,.T.,)


	/////////////////////// BOTÃO 'Inserir' ///////////////////////
	oButton3      := TButton():Create(oJanela, 275,1,"Inserir",{||insertDb(aValores, aValoresN, oJanela)},75,20,,,,.T.,,,,,,)

	oJanela:Activate(,,,.T.,,,)


RETURN


Static Function insertDb(aValores, aValoresN, oJanela)
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
	A2_COD     := aValores[1][1]     				   // Código
	A2_NOME    := aValores[3][1]      				   // Fantasia
	A2_LOJA    := aValores[2][1]                       // Loja
	A2_TIPO    := Left(aValores[8][1], 1)              // Tipo
	A2_END     := aValores[6][1]                       // Endereço
	A2_EST     := getSiglaEst(aValores[4][1])          // Estado
	A2_MUN 	   := aValores[5][1]                       // Município
	A2_NREDUZ  := aValores[7][1]                       // Razao social
	A2_CGC     := aValoresN[1][1]                      // codigo/cpf
	A2_COD_MUN := trataCodMun(aValoresN[2][1])         // codigo municipio
	A2_TEL     := aValoresN[3][1]                      // telefone
	A2_PFISICA := aValoresN[4][1]                  	   // num registro identificaçao
	A2_INSCR   := aValoresN[5][1]  				       // num. inscricao estad.
	A2_INSCRM  := aValoresN[6][1]  				       // num. inscricao municip.
	A2_PAIS    := trataCodMun(aValoresN[8][1])
	A2_DDI     := aValoresN[7][1]
	A2_DDD	   := aValoresN[9][1]
	A2_DEPTO   := aValoresN[11][1]   
	A2_EMAIL   := aValoresN[12][1] 
	A2_HPAGE   := aValoresN[13][1]   
	A2_TELEX   := aValoresN[14][1]  
	A2_ENDCOMP := aValoresN[15][1]   
	A2_MSBLQL  := Left(aValoresN[16][1],1) 				// pegando só o 1 ou 2
	A2_COMPLEM := aValoresN[17][1]  
	A2_FORNEMA := Left(aValoresN[18][1],1) 				// pegando só o 1 ou 2
	A2_CBO     := aValoresN[19][1]   
	A2_CNAE    := aValoresN[20][1]   

	MsUnlock()

	SA2->(dbCloseArea())

	FWAlertSuccess("Fornecedor inserido com sucesso", "Inserido")
	oJanela:end()


RETURN


Static Function update(cIdLinha)
	Local oJanela  := TDialog():New(0, 0, 600, 1100,'Cadastro de fornecedores',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	Local nNumero := 0
	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aValores := {{SA2->A2_COD,'Código'},{SA2->A2_LOJA,'Loja'},{SA2->A2_NOME,'Nome Fantasia'},{SA2->A2_EST,'Estado'},{SA2->A2_MUN,'Municipio'},{SA2->A2_END,'Endereço'},{SA2->A2_NREDUZ,'Razão Social'}, {A2_TIPO,'Tipo'}}
	Local aValoresN := {{SA2->A2_CGC,'CPF/CNPJ'},{'','Código Município'}, {SA2->A2_TEL, 'Telefone'},{SA2->A2_PFISICA, 'RG/Ced.Estr.'}, {SA2->A2_INSCR, 'Ins. Estad.'}, {SA2->A2_INSCRM, 'Ins. Municip.'}, {SA2->A2_DDI, 'DDI'}, {SA2->A2_PAIS,'País'}, {SA2->A2_DDD,'DDD'}}
	Local aTipos := {"F - Físico", "J - Jurídico"}
	LOcal aTiposVerificacao := {"F","J"}
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local aEstados2 := {}
	Local aMunicipios := {}
	Local aPaises 	:= trataPaises()
	Local oLoja
	Local oCodigo
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oCodMun
	Local oRazaoSocial
	Local oTelefone
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,300 )

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next

	oCodigo       := TGet():New( 0, 1, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 9999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 0, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 20, 1, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 40, 1, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 40, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oCodMun		  := TComboBox():New( 20, 100, {|u|if(PCount()>0,aValoresN[2][1]:=u,aValoresN[2][1])}, aMunicipios, 100, , oTFolder:aDialogs[1], , , , , , .T., ,, , , , , , , aValoresN[2][1], aValoresN[2][2], 1, , )

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oEstado       := TComboBox():New( 60, 1, {|u|if(PCount()>0,aValores[4][1]:=u,aValores[4][1])}, aEstados2, 100, , oTFolder:aDialogs[1], ,{||getComboMunicipios(oEstado, @oCodMun)} , , , , .T., ,, , , , , , , aValores[4][1], 'Estado', 1, , )
	oEstado:Select(aScan(aEstadosSiglas, SA2->A2_EST))

	aMunicipios := getMunicipios(oEstado)
	oCodMun:setItems(aMunicipios)
	oCodMun:Select(aScan(aMunicipios, getNomeMun(SA2->A2_COD_MUN,SA2->A2_EST)))


	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 85, 1, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 1, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 1, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[7][1],aValoresN[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[7][1],,,,,,,aValoresN[7][2],1,,,,.T.,)

	oTipo 		  := TComboBox():New( 150, 1, {|u|if(PCount()>0,aValores[8][1]:=u,aValores[8][1])}, aTipos, 100, , oTFolder:aDialogs[1], ,{||verificaCgc(oTipo, @oCGC)} , , , , .T., ,, , , , , , , aValores[8][1], aValores[8][2], 1, , )
	oTipo:Select(AScan(aTiposVerificacao, SA2->A2_TIPO))

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oPais 		  := TComboBox():New( 180, 001, {|u|if(PCount()>0,aValoresN[8][1]:=u,aValoresN[8][1])}, aPaises, 200, , oTFolder:aDialogs[1], ,, , , , .T., ,, , , , , , , aValoresN[8][1], aValoresN[8][2], 1, , )
	selecionaPais(@oPais,SA2->A2_PAIS,aPaises)

	oButton3      := TButton():Create(oJanela,250,1,"Atualizar",{||updateDb(SA2->(RecNo()),aValores, aValoresN, oJanela)},75,20,,,,.T.,,,,,,)

	oJanela:Activate(,,,.T.,,,)



RETURN


Static Function updateDb(recno, aValores, aValoresN, oJanela)
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
	cQryUpd += "a2_nome = '" + AllTrim(aValores[3][1]) + "', "
	cQryUpd += "a2_nreduz = '" + aValores[7][1] + "', "
	cQryUpd += "a2_end = '" + AllTrim(aValores[6][1]) + "', "
	cQryUpd += "a2_est = '" + AllTrim(getSiglaEst(aValores[4][1])) + "', "
	cQryUpd += "a2_mun = '" + AllTrim(aValores[5][1]) + "', "
	cQryUpd += "a2_tipo = '" + Left(aValores[8][1], 1) + "', "
	cQryUpd += "a2_cgc = '" + aValoresN[1][1] + "',  "
	cQryUpd += "a2_cod_mun = '" + trataCodMun(aValoresN[2][1]) + "', "
	cQryUpd += "a2_tel = '" + aValoresN[3][1] + "', "
	cQryUpd += "a2_pfisica = '" + aValoresN[4][1] + "', "
	cQryUpd += "a2_inscr = '" + aValoresN[5][1] + "', "
	cQryUpd += "a2_inscrm = '" + aValoresN[6][1] + "', "
	cQryUpd += "a2_ddi = '" + aValoresN[7][1] + "', "
	cQryUpd += "a2_ddd = '" + aValoresN[9][1] + "', "
	cQryUpd += "a2_pais = '" + trataCodMun(aValoresN[8][1]) + "'"
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
	Local aTFolder := { 'Cadastrais', 'Adm/Fin.', 'Fiscais', 'Compras', 'Direitos autorais', 'TMS', 'Residente Exterior', 'Autônomos', 'Outros' }
	Local aEstados := FWGetSX5("12")
	Local aEstadosSiglas := {}
	Local aValores := {{SA2->A2_COD,'Código'},{SA2->A2_LOJA,'Loja'},{SA2->A2_NOME,'Nome Fantasia'},{SA2->A2_EST,'Estado'},{SA2->A2_MUN,'Municipio'},{SA2->A2_END,'Endereço'},{SA2->A2_NREDUZ,'Razão Social'}, {SA2->A2_TIPO,'Tipo'}}
	Local aValoresN := {{SA2->A2_CGC,'CPF/CNPJ'},{'','Código Município'}, {SA2->A2_TEL, 'Telefone'},{SA2->A2_PFISICA, 'RG/Ced.Estr.'}, {SA2->A2_INSCR, 'Ins. Estad.'}, {SA2->A2_INSCRM, 'Ins. Municip.'}, {SA2->A2_DDI, 'DDI'}, {SA2->A2_PAIS,'País'}, {SA2->A2_DDD,'DDD'}}
	Local aEstados2 := {}
	Local oLoja
	Local oCodigo
	Local oTelefone
	Local oNFantasia
	Local oEstado
	Local oMunicipio
	Local oEndereco
	Local oRazaoSocial
	Local OPFisica
	Local oInscr
	Local oDdi
	Local oDdd
	Local oTFolder := TFolder():New( 0,0,aTFolder,,oJanela,,,,.T.,,551,300 )

	For nNumero := 1 to 26
		AADD(aEstados2, aEstados[nNumero][4])
	next

	For nNumero := 1 to 26
		AADD(aEstadosSiglas, AllTrim(aEstados[nNumero][3]))
	next

	aValoresN[2][1] := getNomeMun(SA2->A2_COD_MUN, aValores[4][1])

	oCodigo       := TGet():New( 000, 001, {|u|if(PCount()==0,aValores[1][1],aValores[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[1][1],,,,,,,aValores[1][2],1,,,,.T.,)

	oCGC		  := TGet():New( 000, 100, {|u|if(PCount()==0,aValoresN[1][1],aValoresN[1][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 999.999.999-99",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[1][1],,,,,,,aValoresN[1][2],1,,,,.T.,)

	oLoja         := TGet():New( 020, 001, {|u|if(PCount()==0,aValores[2][1],aValores[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[2][1],,,,,,,aValores[2][2],1,,,,.T.,)

	oCodMun		  := TGet():New( 020, 100, {|u|if(PCount()==0,aValoresN[2][1],aValoresN[2][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[2][1],,,,,,,aValoresN[2][2],1,,,,.T.,)

	oNFantasia    := TGet():New( 040, 001, {|u|if(PCount()==0,aValores[3][1],aValores[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[3][1],,,,,,,aValores[3][2],1,,,,.T.,)

	oTelefone     := TGet():New( 040, 100, {|u|if(PCount()==0,aValoresN[3][1],aValoresN[3][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@R 9999-9999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[3][1],,,,,,,aValoresN[3][2],1,,,,.T.,)

	oEstado       := TGet():New( 060, 001, {|u|if(PCount()==0,aValores[4][1],aValores[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[4][1],,,,,,,aValores[4][2],1,,,,.T.,)

	OPFisica 	  := TGet():New( 060, 100, {|u|if(PCount()==0,aValoresN[4][1],aValoresN[4][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[4][1],,,,,,,aValoresN[4][2],1,,,,.T.,)

	oMunicipio    := TGet():New( 085, 001, {|u|if(PCount()==0,aValores[5][1],aValores[5][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[5][1],,,,,,,aValores[5][2],1,,,,.T.,)

	oInscr 		  := TGet():New( 085, 100, {|u|if(PCount()==0,aValoresN[5][1],aValoresN[5][1]:=u)},oTFolder:aDialogs[1], 096, 009, "@N 99999999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[5][1],,,,,,,aValoresN[5][2],1,,,,.T.,)

	oEndereco     := TGet():New( 105, 001, {|u|if(PCount()==0,aValores[6][1],aValores[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[6][1],,,,,,, aValores[6][2],1,,,,.T.,)

	oInscrM 	  := TGet():New( 105, 100, {|u|if(PCount()==0,aValoresN[6][1],aValoresN[6][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N XXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[6][1],,,,,,,aValoresN[6][2],1,,,,.T.,)

	oRazaoSocial  := TGet():New( 125, 001, {|u|if(PCount()==0,aValores[7][1],aValores[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[7][1],,,,,,,aValores[7][2],1,,,,.T.,)

	oDdi          := TGet():New( 125, 100, {|u|if(PCount()==0,aValoresN[7][1],aValoresN[7][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[7][1],,,,,,,aValoresN[7][2],1,,,,.T.,)

	oTipo 		  := TGet():New( 150, 001, {|u|if(PCount()==0,aValores[8][1],aValores[8][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@E XXXXXXXXXXXXXXXXXXXX",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValores[8][1],,,,,,,aValores[8][2],1,,,,.T.,)

	oDdd          := TGet():New( 150, 100, {|u|if(PCount()==0,aValoresN[9][1],aValoresN[9][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[9][1],,,,,,,aValoresN[9][2],1,,,,.T.,)

	oPais 		  := TGet():New( 170, 100, {|u|if(PCount()==0,aValoresN[8][1],aValoresN[8][1]:=u)}, oTFolder:aDialogs[1], 096, 009, "@N 999",,0,,,,, .T. /*[ lPixel ]*/,,,,,,,.T.,,, aValoresN[8][1],,,,,,,aValoresN[8][2],1,,,,.T.,)

	oButton3      := TButton():Create(oJanela, 200,1,"Fechar",{||oJanela:end()},75,20,,,,.T.,,,,,,)


	oJanela:Activate(,,,.T.,,,)




RETURN


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
	TRCell():New(oSection, "A2_CGC" , "TRB", "CGC/CPF"    , '@R 999.999.999-99', /*Tamanho*/,  , /*{|| code-block de impressao }*/)

	//Definição da collection
	//oColl:=TRCollection():New("TOTAL UF", "COUNT", /*oBreak*/,"Total POR UF",;
		///*cPicture*/, /*uFormula*/ oSection:Cell("A1_COD"), /*.lEndSection.*/ .F.,;
		///*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,;
		///*uContent*/ oSection:Cell("A1_EST") )

	//oReport:PrintGraphic()
	oReport:PrintDialog()

Return


Static Function ReportPrint(oReport, oSection)

	#IFDEF TOP

		Local cAlias := "TRB"

		BEGIN REPORT QUERY oSection

			BeginSql alias cAlias
            SELECT A2_NOME,A2_TIPO,A2_CGC
            FROM %table:SA2% 
			WHERE %notdel%
			EndSql

		END REPORT QUERY oSection

		//oSection:aCollection[1]:SetGraphic(4,"UF")
		oSection:PrintGraphic()
		oSection:Print()

	#ENDIF

return


Static Function verificaCgc(oTipo, oCGC, oCbo, oCnae)
	Local nTipo := oTipo:nAt
	If nTipo == 1
		oCGC:Picture := "@R 999.999.999-99"
		oCbo:lReadOnly  := .F.
		oCnae:lReadOnly := .T.
		oCnae:cText 	:= ''

	Else
		oCGC:Picture := "@R 99.999.999/9999-99"
		oCnae:lReadOnly := .F.
		oCbo:lReadOnly  := .T.
		oCbo:cText 		:= ''

	Endif

RETURN

Static Function getMunicipios(oEstado)
	Local cQuery
	Local cEstado := AllTrim(FWGetSX5("12")[oEstado:nAt][3])
	Local aMunicipios := {}
	Local aMunicipiosTratado := {}
	Local nI


	cQuery := "SELECT CC2_MUN,CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aMunicipios, , ,)

	For nI := 1 to len(aMunicipios)
		aMunicipiosTratado[nI] := AllTrim(aMunicipios[nI][1]) + ' - '  + aMunicipios[nI][2]
	Next

RETURN aMunicipiosTratado

Static Function getComboMunicipios(oEstado, oCodMunicipio)
	Local cQuery
	Local cEstado := AllTrim(FWGetSX5("12")[oEstado:nAt][3])
	Local aMunicipios := {}
	Local aMunicipiosTratado := {}
	Local nI


	cQuery := "SELECT CC2_MUN,CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aMunicipios, , ,)


	For nI := 1 to len(aMunicipios)
		aMunicipiosTratado[nI] := AllTrim(aMunicipios[nI][1]) + ' - '  + aMunicipios[nI][2]
	Next

	oCodMunicipio:setItems(aMunicipiosTratado)

RETURN


Static Function getNomeMun(cCodMun, cEstado)
	Local cQuery
	Local aResult := {}


	cQuery := "SELECT CC2_MUN, CC2_CODMUN FROM "+ RetSqlName("CC2") + " WHERE CC2_CODMUN LIKE '" + cCodMun + "'" + "AND CC2_EST LIKE '" + cEstado + "'"
	TCSqlToArr( cQuery, aResult, , ,)


RETURN AllTrim(aResult[1][1]) + ' - ' + aResult[1][2]

Static Function trataCodMun(cCodMun)
	Local nPos
	nPos := At("-", cCodMun, 1)
RETURN Right(cCodMun, (Len(cCodMun)-nPos)-1)


Static Function trataNomeMun(cCodMun)
	Local nPos
	nPos := At("-", cCodMun, 1)
RETURN Left(cCodMun, (nPos-2))

Static Function getSiglaEst(cEstado)
	Local aEstados := FWGetSX5("12")
	Local cSigla
	Local nI

	For nI := 1 To Len(aEstados)
		If aEstados[nI][4] == cEstado
			cSigla := aEstados[nI][3]
			RETURN cSigla
		Endif
	Next



RETURN '00'

Static Function getPaises()
	Local cQuery
	Local aResult := {}


	cQuery := "SELECT YA_CODGI, YA_DESCR FROM "+ RetSqlName("SYA")
	TCSqlToArr( cQuery, aResult, , ,) //[1] = cod, [2] = nome

RETURN aResult

Static Function trataPaises()
	Local nI
	Local aPaises := getPaises()

	For nI := 1 to Len(aPaises)
		aPaises[nI] := AllTrim(aPaises[nI][2]) + ' - ' + aPaises[nI][1]
	next



RETURN aPaises


Static Function selecionaPais(oPais, cPais, aPaises)
	Local nI

	For nI := 1 To Len(aPaises)

		If trataCodMun(aPaises[nI]) == cPais
			oPais:Select(nI)
			RETURN
		Endif

	Next



RETURN


Static Function trocaDescPais(cCodPais, oDescPais)
	Local cNome := trataNomeMun(cCodPais)
	oDescPais:cText := cNome
RETURN
