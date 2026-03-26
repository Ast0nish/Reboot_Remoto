Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Gerenciador de Reinício Remoto"
$form.Size = "780,540"
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1E1E1E"
$form.ForeColor = "White"
$form.Font = New-Object System.Drawing.Font("Segoe UI",10)

# TITULO
$titulo = New-Object System.Windows.Forms.Label
$titulo.Text = "Reinícios Agendados"
$titulo.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$titulo.AutoSize = $true
$titulo.Location = "270,10"
$form.Controls.Add($titulo)

# AUTOR
$autor = New-Object System.Windows.Forms.Label
$autor.Text = "By Vinícius Pimentel"
$autor.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Italic)
$autor.AutoSize = $true
$autor.Location = "310,45"
$autor.ForeColor = "#AAAAAA"
$form.Controls.Add($autor)

# LABEL MAQUINA
$labelComp = New-Object System.Windows.Forms.Label
$labelComp.Text = "Máquina:"
$labelComp.Location = "20,70"
$labelComp.AutoSize = $true
$form.Controls.Add($labelComp)

# TEXTBOX
$textComp = New-Object System.Windows.Forms.TextBox
$textComp.Location = "90,68"
$textComp.Size = "180,25"
$form.Controls.Add($textComp)

# LABEL DATA
$labelData = New-Object System.Windows.Forms.Label
$labelData.Text = "Data/Hora:"
$labelData.Location = "290,70"
$labelData.AutoSize = $true
$form.Controls.Add($labelData)

# DATE PICKER COM SEGUNDOS
$dtPicker = New-Object System.Windows.Forms.DateTimePicker
$dtPicker.Format = "Custom"
$dtPicker.CustomFormat = "dd/MM/yyyy HH:mm:ss"
$dtPicker.ShowUpDown = $true
$dtPicker.Location = "370,68"
$dtPicker.Size = "170,25"
$form.Controls.Add($dtPicker)

# BOTAO ADICIONAR
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Adicionar"
$btnAdd.Location = "560,66"
$btnAdd.Size = "120,30"
$btnAdd.BackColor = "#007ACC"
$btnAdd.ForeColor = "White"
$btnAdd.FlatStyle = "Flat"
$form.Controls.Add($btnAdd)

# GRID
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = "20,110"
$grid.Size = "720,320"
$grid.ColumnCount = 4
$grid.Columns[0].Name = "Máquina"
$grid.Columns[1].Name = "Data/Hora"
$grid.Columns[2].Name = "Status"
$grid.Columns[3].Name = "Progresso %"
$grid.Columns[0].Width = 180
$grid.Columns[1].Width = 200
$grid.Columns[2].Width = 170
$grid.Columns[3].Width = 120
$grid.BackgroundColor = "#2D2D30"
$grid.DefaultCellStyle.BackColor = "#2D2D30"
$grid.DefaultCellStyle.ForeColor = "White"
$grid.DefaultCellStyle.SelectionBackColor = "#007ACC"
$grid.DefaultCellStyle.SelectionForeColor = "White"
$grid.ColumnHeadersDefaultCellStyle.BackColor = "#1E1E1E"
$grid.ColumnHeadersDefaultCellStyle.ForeColor = "White"
$grid.EnableHeadersVisualStyles = $false
$form.Controls.Add($grid)

# BOTÃO INICIAR
$btnExecutar = New-Object System.Windows.Forms.Button
$btnExecutar.Text = "Iniciar Agendamentos"
$btnExecutar.Location = "130,450"
$btnExecutar.Size = "180,40"
$btnExecutar.BackColor = "#28A745"
$btnExecutar.ForeColor = "White"
$btnExecutar.FlatStyle = "Flat"
$form.Controls.Add($btnExecutar)

# BOTÃO CANCELAR
$btnCancelar = New-Object System.Windows.Forms.Button
$btnCancelar.Text = "Cancelar Selecionado"
$btnCancelar.Location = "330,450"
$btnCancelar.Size = "180,40"
$btnCancelar.BackColor = "#DC3545"
$btnCancelar.ForeColor = "White"
$btnCancelar.FlatStyle = "Flat"
$form.Controls.Add($btnCancelar)

# BOTÃO REINICIAR AGORA
$btnReiniciar = New-Object System.Windows.Forms.Button
$btnReiniciar.Text = "Reiniciar Agora"
$btnReiniciar.Location = "530,450"
$btnReiniciar.Size = "180,40"
$btnReiniciar.BackColor = "#FF8C00"
$btnReiniciar.ForeColor = "White"
$btnReiniciar.FlatStyle = "Flat"
$form.Controls.Add($btnReiniciar)

# FUNÇÃO DE REINÍCIO ASSÍNCRONO
function Reiniciar-RemotoRunspace {
    param($pc, $row, $grid)
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions = "ReuseThread"
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $ps.AddScript({
        param($pc, $row, $grid)
        try {
            Start-Process "psexec.exe" -ArgumentList "\\$pc -s shutdown -r -t 00" -NoNewWindow
            $grid.Invoke([action]{ $row.Cells[2].Value = "Concluído"; $row.Cells[3].Value = 100 })
        } catch {
            $grid.Invoke([action]{ $row.Cells[2].Value = "Erro"; $row.Cells[3].Value = 0 })
        }
    }).AddArgument($pc).AddArgument($row).AddArgument($grid)
    $ps.BeginInvoke()
}

# FUNÇÃO PARA VERIFICAR HOST SEM BLOQUEAR UI
function Test-HostOnline {
    param($pc)
    try {
        Test-Connection -ComputerName $pc -Count 1 -Quiet -TimeoutSeconds 1 -ErrorAction SilentlyContinue
    } catch { $false }
}

# TIMER
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    foreach($row in $grid.Rows){
        if($row.Cells[0].Value -eq $null){ continue }
        $status = $row.Cells[2].Value
        if($status -eq "Cancelado" -or $status -eq "Concluído"){ continue }

        $pc = $row.Cells[0].Value
        $dataHora = [datetime]$row.Cells[1].Value
        $inicio = $row.Tag
        $agora = Get-Date

        # Verificação rápida de host/IP
        $online = Test-HostOnline $pc
        if(-not $online){
            $row.Cells[2].Value = "Offline"
            $row.Cells[3].Value = 0
            continue
        }

        if($agora -lt $dataHora){
            $total = ($dataHora - $inicio).TotalSeconds
            $restante = ($dataHora - $agora).TotalSeconds
            $percent = if($total -gt 0){ [math]::Round(100 - (($restante/$total)*100)) } else { 0 }
            $row.Cells[2].Value = "Aguardando"
            $row.Cells[3].Value = $percent
        } else {
            $row.Cells[2].Value = "Enviado"
            $row.Cells[3].Value = 100
            Reiniciar-RemotoRunspace $pc $row $grid
            $row.Cells[2].Value = "Reiniciando..."
        }
    }
})

# ADICIONAR MÁQUINA
$btnAdd.Add_Click({
    $pc = $textComp.Text
    $data = $dtPicker.Value
    if([string]::IsNullOrWhiteSpace($pc)){
        [System.Windows.Forms.MessageBox]::Show("Informe a máquina")
        return
    }
    $row = $grid.Rows.Add($pc,$data,"Agendado",0)
    $grid.Rows[$row].Tag = Get-Date
    $textComp.Clear()
})

# INICIAR
$btnExecutar.Add_Click({ $timer.Start() })

# CANCELAR
$btnCancelar.Add_Click({
    if($grid.SelectedRows.Count -eq 0){return}
    $row = $grid.SelectedRows[0]
    $pc = $row.Cells[0].Value
    $row.Cells[2].Value = "Cancelado"
    $row.Cells[3].Value = 0
    Start-Process "psexec.exe" -ArgumentList "\\$pc -s shutdown -a" -NoNewWindow
})

# REINICIAR AGORA
$btnReiniciar.Add_Click({
    if($grid.SelectedRows.Count -eq 0){ [System.Windows.Forms.MessageBox]::Show("Selecione uma máquina na lista."); return }
    $row = $grid.SelectedRows[0]
    $pc = $row.Cells[0].Value
    $online = Test-HostOnline $pc
    if(-not $online){ [System.Windows.Forms.MessageBox]::Show("Máquina offline."); return }

    $resposta = [System.Windows.Forms.MessageBox]::Show(
        "Reiniciar $pc agora?",
        "Confirmação",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if($resposta -eq "Yes"){
        $row.Cells[2].Value = "Reiniciando..."
        $row.Cells[3].Value = 100
        Reiniciar-RemotoRunspace $pc $row $grid
    }
})

$form.Topmost = $true
$form.ShowDialog()
