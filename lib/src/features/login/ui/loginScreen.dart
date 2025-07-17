import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc loginBloc = LoginBloc();
  bool evOwner = false;
  bool systemOperator = false;
  @override
  void initState() {
    loginBloc.add(EvOwnerButtonClickedEvent());
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return BlocConsumer<LoginBloc, LoginState>(
      bloc: loginBloc,
      listenWhen: (previous, current) => current is LoginActionState,
      buildWhen: (previous, current) => current is! LoginActionState,
  listener: (context, state) {
    // TODO: implement listener
  },
  builder: (context, state) {
    if(state is EvOwnerClickedState){
      evOwner = true;
      systemOperator = false;

    }if(state is SystemOperatorClickedState){
      evOwner = false;
      systemOperator = true;
    }
    return Scaffold(
      backgroundColor: Color(0xFF030A10),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Padding(
              padding:  EdgeInsets.only(top: height*0.07),
              child: Stack(
                children: [
      
                  SizedBox(
                    width: width,
                      height: height*0.35,
                      child: Image(image: AssetImage("assets/images/carImage.jpg"),fit: BoxFit.cover,)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Power",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25.0),),
                      Text("Sync",style: TextStyle(color: Color(0xFF22C79F),fontWeight: FontWeight.bold,fontSize: 25.0),),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: (){
                      loginBloc.add(EvOwnerButtonClickedEvent());
                    },
                    child: Container(
                      width: width*0.25,
                      height: 30.0,
                      decoration: BoxDecoration(
                        border: evOwner ? Border( bottom: BorderSide(color: Color(0xFF22C79F))):Border( bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))) ,
                      ),
                      child: Center(child: Text("EV Owner",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15.0),)),
                    
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7.0),
                  child: GestureDetector(
                    onTap: (){
                      loginBloc.add(SystemOperatorButtonClickedEvent());
                    },
                    child: Container(
                      width: width*0.35,
                      height: 30.0,
                      decoration: BoxDecoration(
                        border:systemOperator ? Border( bottom: BorderSide(color: Color(0xFF22C79F))):Border( bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))) ,
                      ),
                      child: Center(child: Text("System Operator",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15.0),)),
                    
                    ),
                  ),
                ),
              ],
            ),
      
          ],
          
        ),
    );
  },
);
  }

  Future<Widget> evOwnerPart () async {
    return Column(
      children: [

      ],
    );
  }

}
