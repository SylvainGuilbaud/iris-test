from iop import BusinessOperation

class MyBo(BusinessOperation):
    def on_message(self, request):
        self.log_info("Hello World")