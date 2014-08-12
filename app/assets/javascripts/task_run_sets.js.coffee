jQuery ->
  $('#task_run_sets').dataTable
    sDom: "<'row'<'span8'l><'span8'f>r>t<'row'<'span8'i><'span8'p>>"
    bJQueryUI: true
    sPaginationType: "scrolling"
    sScrollY: "500px"
    sDom: "frtiS"
    bDeferRender: true
    bProcessing: true
    bServerSide: false
    iDisplayLength: 50
    aaSorting: [ [3,'desc'] ],
    aoColumns: [
      { "sTitle": "Task", "sWidth": "50%" },
      { "sTitle": "Tasks Started", "sWidth": "10%" },
      { "sTitle": "Total Tasks", "sWidth": "10%" },
      { "sTitle": "Updated At", "sWidth": "30%" },
    ]
    sAjaxSource: $('#task_run_sets').data('source')
