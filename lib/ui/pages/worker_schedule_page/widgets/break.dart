import 'package:flutter/material.dart';
import 'package:management_system_app/models/break_model.dart';
import 'package:management_system_app/ui/general_widgets/buttons/note_button.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/times_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../general_widgets/dialogs/make_sure_dialog.dart';

class Break extends StatelessWidget {
  final BreakModel breakModel;
  final BuildContext ancetorContext;

  final double height = gHeight * 0.1;
  Break({
    super.key,
    required this.breakModel,
    required this.ancetorContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      height: MediaQuery.of(context).textScaleFactor * height,
      decoration: BoxDecoration(
          border: this.breakModel.color == 0
              ? null
              : Border.all(color: Color(this.breakModel.color), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).textScaleFactor * height - 15,
              width: 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: this.breakModel.color == 0
                      ? null
                      : Color(this.breakModel.color)),
            ),
          ),
          Positioned(
            top: 14,
            left: 6,
            child: Row(
              children: [
                GestureDetector(
                    onTap: () async {
                      bool? resp = await makeSureDialog(context,
                          translate("doDelete") + translate("break") + "?");
                      if (resp == true)
                        await Loading(
                                context: ancetorContext,
                                navigator: Navigator.of(ancetorContext),
                                future: WorkerData.removeBreak(breakModel),
                                animation: deleteAnimation,
                                msg: translate("breakDeletedSuccessfully"))
                            .dialog();
                    },
                    child: Icon(Icons.delete)),
                SizedBox(width: 10),
                NoteButton(breakModel: breakModel),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 6,
            child: Text(translate("start") + ": " + breakModel.start,
                style: TextStyle(fontSize: 16)),
          ),
          Positioned(
            bottom: 10,
            right: 6,
            child: Text(
                translate("end") +
                    ": " +
                    addDurationFromDateString(
                        breakModel.start, breakModel.duration),
                style: TextStyle(fontSize: 16)),
          ),
          Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: gWidth * 0.35,
                child: Text(
                  this.breakModel.title != ""
                      ? this.breakModel.title
                      : translate("break"),
                  style: TextStyle(
                      fontSize: 18, color: Color(this.breakModel.color)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Text(durationToString(this.breakModel.duration),
                  textAlign: TextAlign.center),
            ]),
          ),
        ],
      ),
    );
  }
}
